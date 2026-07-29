#pragma once

#include "catalog/distro.h"

#include <QObject>
#include <QVariantMap>

class QTcpSocket;
class QProcess;
class QTimer;

// One running QEMU process. Talks QMP over TCP on localhost
// to read guest RAM from virtio-balloon and to power the guest down gracefully.
class VmSession : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("Started via VmManager.start()")
    Q_PROPERTY(QString distroId READ distroId CONSTANT)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString error READ error NOTIFY stateChanged)
    Q_PROPERTY(int guestRamUsedMb READ guestRamUsedMb NOTIFY statsChanged) // 0 until known
    Q_PROPERTY(int guestRamTotalMb READ guestRamTotalMb NOTIFY statsChanged)

public:
    enum State { Starting, Running, Stopped, Failed };
    Q_ENUM(State)

    VmSession(const QString &distroId, const QString &program, const QStringList &arguments,
              quint16 qmpPort, QObject *parent);
    ~VmSession() override; // closing Testux ends the VM with it

    QString distroId() const { return m_distroId; }
    State state() const { return m_state; }
    QString error() const { return m_error; }
    int guestRamUsedMb() const { return m_ramUsedMb; }
    int guestRamTotalMb() const { return m_ramTotalMb; }

    void launch();
    Q_INVOKABLE void stop(); // ACPI power button, kills QEMU if the guest ignores it

signals:
    void stateChanged();
    void statsChanged();

private:
    void setState(State state, const QString &error = {});

    QString m_distroId;
    QProcess *m_process;
    QTcpSocket *m_qmp;
    QTimer *m_statsTimer;
    quint16 m_qmpPort;
    State m_state = Starting;
    QString m_error;
    int m_ramUsedMb = 0;
    int m_ramTotalMb = 0;
};

// Finds QEMU, picks the accelerator and runs at most one VM at a time. Test disks live in
// AppLocalDataLocation/disks/<distroId>.qcow2 (30 GiB, thin). The RAM a distro
// uses about two minutes after boot, idle at its desktop, is kept in QSettings for the comparison
// page.
class VmManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(QString accelerator READ accelerator CONSTANT)
    Q_PROPERTY(QString setupHint READ setupHint CONSTANT)
    Q_PROPERTY(VmSession *session READ session NOTIFY sessionChanged)

public:
    explicit VmManager(QObject *parent = nullptr);

    bool available() const { return !m_qemu.isEmpty(); }
    QString accelerator() const { return m_accelerator; } // "kvm", "whpx" or "tcg"
    // What the user should do to get a fast VM: install QEMU, join the kvm group, enable
    // the Windows Hypervisor Platform. "" when everything is in place.
    QString setupHint() const { return m_setupHint; }
    VmSession *session() const { return m_session; }

    // Stops a running session first. Returns nullptr if QEMU is missing.
    Q_INVOKABLE VmSession *start(const Distro &distro, const QString &isoPath, bool withTestDisk);
    Q_INVOKABLE bool hasTestDisk(const QString &distroId) const;
    Q_INVOKABLE void removeTestDisk(const QString &distroId);
    // {"ramUsedMb": int, "measuredAt": QDateTime} or empty when never measured.
    Q_INVOKABLE QVariantMap measurement(const QString &distroId) const;

signals:
    void sessionChanged();
    void testDisksChanged();
    void measurementsChanged();

private:
    QString m_qemu;
    QString m_qemuImg;
    QString m_firmware;
    QString m_accelerator;
    QString m_setupHint;
    VmSession *m_session = nullptr;
};
