#pragma once

#include "catalog/distro.h"

#include <QObject>

#include <functional>

// Boots a live ISO on this PC without a USB stick (Windows, UEFI, GPT only).
//
// prepare() runs scripts/prepare-boot.ps1 elevated. The script shrinks C:, creates a FAT32
// partition labelled TESTUX holding the ISO contents, leaves `linuxSpaceGb` unallocated for
// the distro installer, suspends BitLocker for one reboot, adds a firmware boot entry and
// makes it the one-time BootNext. On success the app registers "Testux.exe --post-boot" in
// RunOnce so it can offer the cleanup when the user is back in Windows.
//
// Progress is exchanged through %ProgramData%\Testux\: the script appends JSON lines tagged
// with the run id it was given ({"run": id, "step": "copy", "progress": 0.4} / {"run": id,
// "error": "..."} / {"run": id, "done": true}) to progress.jsonl and records every change in
// boot.json before making it; cleanup-boot.ps1 reads boot.json to undo exactly those
// changes and deletes it when finished. If the partition no longer matches the record it
// is left untouched, everything else is undone and boot.json is moved aside, so the
// setup stops being pending ({"run": id, "error": "...", "code": "partition-untouched"}).
class BareMetal : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool supported READ supported CONSTANT)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString step READ step NOTIFY progressChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString error READ error NOTIFY stateChanged)
    Q_PROPERTY(bool pending READ pending NOTIFY stateChanged) // boot.json exists
    Q_PROPERTY(bool postBoot READ postBoot CONSTANT)          // started with --post-boot

public:
    enum State { Idle, Working, ReadyToReboot, Failed };
    Q_ENUM(State)

    explicit BareMetal(QObject *parent = nullptr);

    bool supported() const;
    State state() const { return m_state; }
    QString step() const { return m_step; }
    double progress() const { return m_progress; }
    QString error() const { return m_error; }
    bool pending() const;
    bool postBoot() const { return m_postBoot; }

    Q_INVOKABLE void prepare(const Distro &distro, const QString &isoPath, int linuxSpaceGb);
    Q_INVOKABLE void reboot();
    // Removes the TESTUX partition and boot entry. With reclaimSpace the unallocated space
    // next to C: is given back to Windows, which only exists if Linux was not installed.
    Q_INVOKABLE void cleanup(bool reclaimSpace);

signals:
    void stateChanged();
    void progressChanged();

private:
    enum class Operation { None, Prepare, Cleanup };

    void startScript(Operation operation, const QString &script, QStringList arguments);
    void pollProgress();
    void onScriptFinished(int exitCode);
    void finish(State state, const QString &error = {});
    void setState(State state, const QString &error = {});

    QTimer *m_poll;
    Operation m_operation = Operation::None;
    QString m_runId;
    QString m_stepId;
    State m_state = Idle;
    QString m_step;
    double m_progress = 0;
    QString m_error;
    bool m_postBoot = false;
};

// Platform part, baremetal_win.cpp or baremetal_stub.cpp.
namespace BareMetalPlatform {

bool supported();  // Windows booted in UEFI mode
QString dataDir(); // %ProgramData%\Testux, "" where unsupported

bool rebootNow(QString *error);

// Adds or removes "Testux.exe --post-boot" in the current user's RunOnce key.
void setLaunchAfterReboot(bool enabled);

} // namespace BareMetalPlatform
