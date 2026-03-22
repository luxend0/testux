#include "catalog/catalog.h"

#include "catalog/catalogparser.h"

using namespace Qt::StringLiterals;

namespace {

QByteArray readFile(const QString &path)
{
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

void writeCache(const QByteArray &json)
{
    QDir().mkpath(QFileInfo(cachePath()).absolutePath());
    QSaveFile file(cachePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(json);
        file.commit();
    }
}

} // namespace
