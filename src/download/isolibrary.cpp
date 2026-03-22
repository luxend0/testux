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
