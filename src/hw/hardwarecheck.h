#pragma once

#include "catalog/distro.h"
#include "hw/hardware.h"

class HardwareCheck : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(HardwareReport report READ report NOTIFY reportChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    explicit HardwareCheck(QObject *parent = nullptr);

    HardwareReport report() const { return m_hw; }
    bool busy() const { return m_busy; }

    Q_INVOKABLE void run(); // ignored while busy; the constructor runs it once
    Q_INVOKABLE QList<CheckResult> evaluate(const Distro &distro, int linuxSpaceGb) const;
    Q_INVOKABLE bool canBoot(const Distro &distro, int linuxSpaceGb) const;
    Q_INVOKABLE qint64 requiredBytes(const Distro &distro, int linuxSpaceGb) const;

signals:
    void reportChanged();
    void busyChanged();

private:
    HardwareReport m_hw;
    bool m_busy = false;
};
