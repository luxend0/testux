#pragma once

#include "catalog/distro.h"

#include <QStringList>

// The "Which Linux suits you?" quiz: three answers in, a short list of distros out.
namespace Recommend {

struct Answers
{
    QString purpose; // "everyday", "gaming", "creative", "oldpc"
    QString look;    // "windows", "mac", "modern"
    QString tinker;  // "none", "some", "lots"
};

struct Pick
{
    QString id;
    QStringList reasons; // already translated, best first, at most two
};

// Best matches first, at most one per distro name (no three Fedora spins), only entries
// with a live session so the user can try them in a window.
QList<Pick> pick(const QList<Distro> &distros, const Answers &answers, int count = 3);

} // namespace Recommend
