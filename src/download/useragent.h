#pragma once

#include <QByteArray>
#include <QCoreApplication>

// How Testux introduces itself to download servers. SourceForge answers Qt's default
// "Mozilla/5.0" with 403, a plain product name gets the usual mirror redirect.
inline QByteArray userAgent()
{
    return "Testux/" + QCoreApplication::applicationVersion().toLatin1();
}
