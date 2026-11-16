#include "catalog/recommend.h"

#include <QCoreApplication>
#include <QSet>

#include <algorithm>

using namespace Qt::StringLiterals;

namespace {

// Well known and friendly first. Breaks ties so equal scores pick what most guides recommend.
// ponytail: hand-kept list, a download/popularity number in the catalog would replace it.
const QStringList Popular{
    u"linuxmint-cinnamon"_s, u"zorin-core"_s,         u"ubuntu"_s,       u"fedora-workstation"_s,
    u"kubuntu"_s,            u"popos"_s,              u"bazzite"_s,      u"nobara"_s,
    u"cachyos"_s,            u"fedora-kde"_s,         u"linuxmint-xfce"_s, u"xubuntu"_s,
    u"mx-xfce"_s,            u"lubuntu"_s,            u"ubuntu-studio"_s, u"endeavouros"_s,
    u"ubuntu-budgie"_s,      u"opensuse-tumbleweed"_s,
};

// Good picks for programming that the catalog files under other categories.
const QSet<QString> DeveloperFriendly{u"fedora-workstation"_s, u"ubuntu"_s, u"popos"_s,
                                      u"endeavouros"_s,        u"bluefin"_s, u"nixos"_s};

const QSet<QString> WindowsLike{u"Cinnamon"_s, u"KDE Plasma"_s, u"Xfce"_s, u"MATE"_s, u"LXQt"_s};
const QSet<QString> MacLike{u"Budgie"_s, u"Pantheon"_s, u"DDE"_s};
const QSet<QString> Modern{u"GNOME"_s, u"COSMIC"_s, u"KDE Plasma"_s};

struct Scored
{
    const Distro *distro;
    double score = 0;
    QList<std::pair<double, QString>> reasons; // (weight, text)

    void add(double points, const QString &reason = {})
    {
        score += points;
        if (points > 0 && !reason.isEmpty())
            reasons.append({points, reason});
    }
};

void scorePurpose(Scored &s, const QString &purpose)
{
    const Distro &d = *s.distro;
    if (purpose == "everyday"_L1) {
        s.add(d.category == "beginner"_L1 ? 4 : 0, QCoreApplication::translate("Recommend", "Easy for everyday use"));
        s.add(d.category == "kde"_L1 || d.category == "other"_L1 ? 1 : 0);
    } else if (purpose == "gaming"_L1) {
        s.add(d.category == "gaming"_L1 ? 6 : 0, QCoreApplication::translate("Recommend", "Set up for gaming"));
        s.add(d.nvidiaReady ? 1 : 0, QCoreApplication::translate("Recommend", "NVIDIA driver included"));
    } else if (purpose == "creative"_L1) {
        s.add(d.category == "creative"_L1 ? 4 : 0, QCoreApplication::translate("Recommend", "Comes with creative apps"));
        s.add(DeveloperFriendly.contains(d.id) ? 4 : 0, QCoreApplication::translate("Recommend", "Great for programming"));
    } else if (purpose == "oldpc"_L1) {
        s.add(d.category == "lightweight"_L1 ? 7 : 0, QCoreApplication::translate("Recommend", "Runs well on older PCs"));
        s.add(d.minRamMb >= 4096 ? -3 : 0);
    }
}

void scoreLook(Scored &s, const QString &look)
{
    const Distro &d = *s.distro;
    const bool zorin = d.id == "zorin-core"_L1; // GNOME, but ships Windows and macOS layouts
    if (look == "windows"_L1) {
        s.add(WindowsLike.contains(d.desktop) || zorin ? 3 : 0,
              QCoreApplication::translate("Recommend", "Taskbar and start menu like Windows"));
    } else if (look == "mac"_L1) {
        s.add(MacLike.contains(d.desktop) ? 3 : d.desktop == "GNOME"_L1 || zorin ? 2 : 0,
              QCoreApplication::translate("Recommend", "Feels a bit like macOS"));
    } else if (look == "modern"_L1) {
        s.add(d.desktop == "COSMIC"_L1 ? 3 : Modern.contains(d.desktop) ? 2 : 0,
              QCoreApplication::translate("Recommend", "A clean, modern desktop"));
    }
}

void scoreTinker(Scored &s, const QString &tinker)
{
    const Distro &d = *s.distro;
    const bool advanced = d.category == "advanced"_L1;
    if (tinker == "none"_L1) {
        s.add(advanced ? -6 : 0);
        s.add(d.category == "beginner"_L1 ? 2 : 0, QCoreApplication::translate("Recommend", "Works out of the box"));
        s.add(d.releaseModel == "fixed"_L1 ? 1 : 0);
    } else if (tinker == "some"_L1) {
        s.add(advanced ? -2 : 0);
    } else if (tinker == "lots"_L1) {
        s.add(advanced ? 3 : 0, QCoreApplication::translate("Recommend", "Lets you change everything"));
        s.add(d.releaseModel == "rolling"_L1 ? 1 : 0, QCoreApplication::translate("Recommend", "Always the newest software"));
    }
}

} // namespace

QList<Recommend::Pick> Recommend::pick(const QList<Distro> &distros, const Answers &answers,
                                       int count)
{
    QList<Scored> scored;
    for (const Distro &distro : distros) {
        // Security and privacy toolkits are a deliberate choice, never a quiz answer.
        if (!distro.liveSession || distro.category == "privacy"_L1)
            continue;
        Scored s{&distro};
        scorePurpose(s, answers.purpose);
        scoreLook(s, answers.look);
        scoreTinker(s, answers.tinker);
        const qsizetype rank = Popular.indexOf(distro.id);
        s.add(rank < 0 ? 0 : 0.9 * (Popular.size() - rank) / Popular.size());
        scored.append(s);
    }
    std::stable_sort(scored.begin(), scored.end(),
                     [](const Scored &a, const Scored &b) { return a.score > b.score; });

    QList<Pick> picks;
    QSet<QString> names;
    for (Scored &s : scored) {
        if (picks.size() >= count)
            break;
        if (names.contains(s.distro->name))
            continue;
        names.insert(s.distro->name);
        std::stable_sort(s.reasons.begin(), s.reasons.end(),
                         [](const auto &a, const auto &b) { return a.first > b.first; });
        Pick pick{s.distro->id, {}};
        for (const auto &[weight, reason] : s.reasons.mid(0, 2))
            pick.reasons.append(reason);
        picks.append(pick);
    }
    return picks;
}
