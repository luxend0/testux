#pragma once

#include <QList>
#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

// One "try this" entry of the test checklist, already resolved to the UI language.
struct ChecklistItem
{
    Q_GADGET
    QML_VALUE_TYPE(checklistItem)
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString title MEMBER title)
    Q_PROPERTY(QString detail MEMBER detail)

public:
    QString id;
    QString title;
    QString detail;

    bool operator==(const ChecklistItem &) const = default;
};

// A catalog entry. Text fields are already resolved to the UI language.
struct Distro
{
    Q_GADGET
    QML_VALUE_TYPE(distro)
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString edition MEMBER edition)
    Q_PROPERTY(QString version MEMBER version)
    Q_PROPERTY(QString category MEMBER category)
    Q_PROPERTY(QString summary MEMBER summary)
    Q_PROPERTY(QString description MEMBER description)
    Q_PROPERTY(QString notes MEMBER notes)
    Q_PROPERTY(QString website MEMBER website)
    Q_PROPERTY(QString color MEMBER color)
    Q_PROPERTY(QString desktop MEMBER desktop)
    Q_PROPERTY(QString base MEMBER base)
    Q_PROPERTY(QString releaseModel MEMBER releaseModel)
    Q_PROPERTY(QString isoUrl MEMBER isoUrl)
    Q_PROPERTY(QString isoSha256 MEMBER isoSha256)
    Q_PROPERTY(QString isoSha256Url MEMBER isoSha256Url)
    Q_PROPERTY(qint64 isoSize MEMBER isoSize)
    Q_PROPERTY(bool secureBoot MEMBER secureBoot)
    Q_PROPERTY(bool liveSession MEMBER liveSession)
    Q_PROPERTY(bool nvidiaReady MEMBER nvidiaReady)
    Q_PROPERTY(int minRamMb MEMBER minRamMb)
    Q_PROPERTY(QList<ChecklistItem> checklist MEMBER checklist)

public:
    QString id;           // stable key, e.g. "linuxmint-cinnamon"
    QString name;         // "Linux Mint"
    QString edition;      // "Cinnamon", may be empty
    QString version;      // "22.2"
    QString category;     // id of one of the catalog's categories, e.g. "beginner"
    QString summary;      // one line for the card
    QString description;  // a short paragraph for the detail page
    QString notes;        // caveats such as "no live session", may be empty
    QString website;
    QString color;        // brand-ish accent, "#rrggbb"
    QString desktop;      // "KDE Plasma"
    QString base;         // "Ubuntu", "Arch", "independent", ...
    QString releaseModel; // "fixed" or "rolling"
    QString isoUrl;
    QString isoSha256;    // lowercase hex, empty when isoSha256Url is used instead
    QString isoSha256Url; // SHA256SUMS-style file listing the ISO
    qint64 isoSize = 0;   // bytes, approximate is fine
    bool secureBoot = false;  // boots with Secure Boot on (signed shim)
    bool liveSession = true;  // false = the ISO only runs an installer
    bool nvidiaReady = false; // ISO ships or offers the proprietary NVIDIA driver
    int minRamMb = 2048;
    QList<ChecklistItem> checklist; // distro specific extras on top of the shared list

    bool isValid() const { return !id.isEmpty(); }
    bool operator==(const Distro &) const = default;
};
