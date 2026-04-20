#include "download/isolibrary.h"

#include "download/checksum.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QLocale>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QQmlEngine>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QtConcurrentRun>

using namespace Qt::StringLiterals;

namespace {

// Left free on the cache drive after the download, so Testux never fills it to the brim.
constexpr qint64 SpaceMargin = 512LL * 1024 * 1024;
// Inactivity limit: a stalled connection fails instead of hanging, slow ones are fine.
constexpr int TransferTimeoutMs = 60 * 1000;

QString partPath(const QString &isoPath)
{
    return isoPath + u".part"_s;
}

int httpStatus(const QNetworkReply *reply)
{
    return reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
}

} // namespace

// The .part file opened for appending, together with the hash of everything written to it.
struct IsoDownload::Part
{
    explicit Part(const QString &path) : file(path) {}

    // Opens or creates the file and hashes what an earlier attempt left in it. Blocking.
    bool open() { return file.open(QIODevice::ReadWrite) && hash.addData(&file); }

    bool append(const QByteArray &chunk)
    {
        if (file.write(chunk) != chunk.size())
            return false;
        hash.addData(chunk);
        return true;
    }

    void truncate()
    {
        file.resize(0);
        file.seek(0);
        hash.reset();
    }

    QString sha256() const { return QString::fromLatin1(hash.result().toHex()); }

    QFile file;
    QCryptographicHash hash{QCryptographicHash::Sha256};
    bool rangeChecked = false;
};

IsoDownload::IsoDownload(const Distro &distro, const QString &path, QNetworkAccessManager *network,
                         QObject *parent)
    : QObject(parent), m_distro(distro), m_path(path), m_network(network), m_total(distro.isoSize)
{
    // Only verified ISOs are ever renamed to `path`, so an existing file needs no recheck.
    if (QFileInfo::exists(m_path)) {
        m_state = Ready;
        m_received = m_total = QFileInfo(m_path).size();
    } else {
        m_received = QFileInfo(partPath(m_path)).size();
    }
}

void IsoDownload::start()
{
    if (m_state == Downloading || m_state == Verifying || m_state == Ready)
        return;

    const QString dir = QFileInfo(m_path).absolutePath();
    QDir().mkpath(dir);
    const qint64 needed =
        qMax(0LL, m_distro.isoSize - QFileInfo(partPath(m_path)).size()) + SpaceMargin;
    const qint64 available = QStorageInfo(dir).bytesAvailable();
    if (available >= 0 && available < needed) {
        setState(Failed, tr("Not enough free disk space. The download needs %1 more.")
                             .arg(QLocale().formattedDataSize(needed - available)));
        return;
    }

    const auto part = std::make_shared<Part>(partPath(m_path));
    m_part = part;
    setState(Downloading);
    QtConcurrent::run([part] { return part->open(); }).then(this, [this, part](bool opened) {
        if (m_part != part)
            return; // cancelled or restarted while hashing
        if (!opened) {
            m_part.reset();
            setState(Failed,
                     tr("Cannot write %1.").arg(QDir::toNativeSeparators(partPath(m_path))));
            return;
        }
        download();
    });
}

void IsoDownload::cancel()
{
    if (m_state != Downloading && m_state != Verifying)
        return;
    m_part.reset();
    if (QNetworkReply *reply = std::exchange(m_reply, nullptr)) {
        reply->disconnect(this);
        reply->abort();
        reply->deleteLater();
    }
    setState(Missing);
}

void IsoDownload::remove()
{
    cancel();
    if (QFileInfo::exists(m_path) && !QFile::remove(m_path)) {
        setState(Ready, tr("Could not delete the ISO. Is a VM still using it?"));
        return;
    }
    QFile::remove(partPath(m_path));
    m_received = 0;
    m_total = m_distro.isoSize;
    emit progressChanged();
    setState(Missing);
}

// Requests whatever the .part file is still missing.
void IsoDownload::download()
{
    QNetworkRequest request{QUrl(m_distro.isoUrl)};
    request.setTransferTimeout(TransferTimeoutMs);
    const qint64 offset = m_part->file.size();
    if (offset > 0)
        request.setRawHeader("Range", "bytes=" + QByteArray::number(offset) + '-');

    m_received = offset;
    emit progressChanged();

    m_reply = m_network->get(request);
    connect(m_reply, &QNetworkReply::readyRead, this, &IsoDownload::receive);
    connect(m_reply, &QNetworkReply::finished, this, &IsoDownload::transferFinished);
}

void IsoDownload::receive()
{
    const int status = httpStatus(m_reply);
    if (status != 200 && status != 206)
        return; // an error page, not ISO data; transferFinished() reports it

    if (!m_part->rangeChecked) {
        m_part->rangeChecked = true;
        if (status == 200) // the server ignored the Range header and sends everything
            m_part->truncate();
        m_received = m_part->file.size();
        const qint64 remaining = m_reply->header(QNetworkRequest::ContentLengthHeader).toLongLong();
        m_total = remaining > 0 ? m_received + remaining : m_distro.isoSize;
    }

    const QByteArray chunk = m_reply->readAll();
    if (!m_part->append(chunk)) {
        const QString reason = m_part->file.errorString();
        cancel();
        setState(Failed, tr("Writing the ISO failed: %1").arg(reason));
        return;
    }
    m_received += chunk.size();
    emit progressChanged();
}

void IsoDownload::transferFinished()
{
    QNetworkReply *reply = std::exchange(m_reply, nullptr);
    reply->deleteLater();

    // 416 means there is nothing left to fetch: the .part was already complete.
    const bool alreadyComplete = httpStatus(reply) == 416 && m_part->file.size() > 0;
    if (reply->error() != QNetworkReply::NoError && !alreadyComplete) {
        m_part.reset();
        setState(Failed, tr("Download failed: %1").arg(reply->errorString()));
        return;
    }

    const QString actualSha256 = m_part->sha256();
    m_part.reset(); // closes the file before it gets renamed
    setState(Verifying);
    verify(actualSha256);
}

void IsoDownload::verify(const QString &actualSha256)
{
    if (!m_distro.isoSha256.isEmpty()) {
        complete(actualSha256, m_distro.isoSha256);
        return;
    }

    QNetworkRequest request{QUrl(m_distro.isoSha256Url)};
    request.setTransferTimeout(TransferTimeoutMs);
    m_reply = m_network->get(request);
    connect(m_reply, &QNetworkReply::finished, this, [this, actualSha256] {
        QNetworkReply *reply = std::exchange(m_reply, nullptr);
        reply->deleteLater();
        if (reply->error() != QNetworkReply::NoError) {
            setState(Failed, tr("Could not fetch the checksum: %1").arg(reply->errorString()));
            return;
        }
        const QString isoName = QUrl(m_distro.isoUrl).fileName();
        complete(actualSha256, Checksum::findSha256(reply->readAll(), isoName));
    });
}

void IsoDownload::complete(const QString &actualSha256, const QString &expectedSha256)
{
    // Keep the .part: the data may be fine and a corrected catalog can still verify it.
    if (expectedSha256.isEmpty()) {
        setState(
            Failed,
            tr("The checksum list does not mention %1.").arg(QUrl(m_distro.isoUrl).fileName()));
        return;
    }
    if (actualSha256.compare(expectedSha256, Qt::CaseInsensitive) != 0) {
        QFile::remove(partPath(m_path));
        m_received = 0;
        emit progressChanged();
        setState(Failed, tr("The download is damaged (checksum mismatch). Please try again."));
        return;
    }
    if (!QFile::rename(partPath(m_path), m_path)) {
        setState(Failed, tr("Could not move the ISO to %1.").arg(QDir::toNativeSeparators(m_path)));
        return;
    }
    m_received = m_total = QFileInfo(m_path).size();
    emit progressChanged();
    setState(Ready);
}

IsoLibrary::IsoLibrary(QObject *parent)
    : QObject(parent),
      m_dir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + u"/isos"_s),
      m_network(new QNetworkAccessManager(this))
{
}

IsoDownload *IsoLibrary::iso(const Distro &distro)
{
    if (!distro.isValid())
        return nullptr;

    // Keyed by the ISO file name, so a catalog version bump means a fresh download instead
    // of reusing the old release. ponytail: rolling "current" links keep their name, so an
    // already cached one is not refreshed until the user removes it.
    QString fileName = QUrl(distro.isoUrl).fileName();
    if (fileName.isEmpty())
        fileName = distro.id + u".iso"_s;

    IsoDownload *&download = m_isos[fileName];
    if (!download) {
        download = new IsoDownload(distro, m_dir + u'/' + fileName, m_network, this);
        QQmlEngine::setObjectOwnership(download, QQmlEngine::CppOwnership);
        connect(download, &IsoDownload::stateChanged, this, &IsoLibrary::usedBytesChanged);
    }
    return download;
}

void IsoLibrary::removeAll()
{
    for (IsoDownload *download : std::as_const(m_isos))
        download->remove();
    // Also files of distros that were dropped from the catalog.
    const QDir dir(m_dir);
    for (const QString &name : dir.entryList({u"*.iso"_s, u"*.part"_s}, QDir::Files))
        QFile::remove(dir.filePath(name));
    emit usedBytesChanged();
}

qint64 IsoLibrary::usedBytes() const
{
    qint64 total = 0;
    for (const QFileInfo &file : QDir(m_dir).entryInfoList(QDir::Files))
        total += file.size();
    return total;
}
