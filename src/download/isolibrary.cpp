#include "download/isolibrary.h"

#include "download/checksum.h"

using namespace Qt::StringLiterals;

namespace {

QString partPath(const QString &isoPath)
{
    return isoPath + u".part"_s;
}

int httpStatus(const QNetworkReply *reply)
{
    return reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
}

} // namespace

struct IsoDownload::Part
{
    explicit Part(const QString &path) : file(path) {}

    // Opens or creates the file and hashes what an earlier attempt left in it. Blocking.
    bool open() { return file.open(QIODevice::ReadWrite) && hash.addData(&file); }

    bool append(const QByteArray &chunk)
    {
        // TODO: handle failure
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
