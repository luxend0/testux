#include "catalog/catalog.h"

#include "catalog/catalogparser.h"

using namespace Qt::StringLiterals;

namespace {

QByteArray readFile(const QString &path)
{
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

} // namespace
