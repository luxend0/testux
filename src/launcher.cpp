#include "launcher.h"

#include "vm/qemuargs.h"

#include <QThread>

Launcher::Launcher(QObject *parent)
    : QObject(parent)
{
    connect(&m_qemu, &QProcess::stateChanged, this, &Launcher::runningChanged);
}

bool Launcher::running() const
{
    return m_qemu.state() != QProcess::NotRunning;
}

void Launcher::start(const QString &isoPath, int ramMb)
{
    if (running())
        return;

    QemuConfig config;
    config.isoPath = isoPath;
    config.accelerator = "kvm";
    config.ramMb = ramMb;
    config.cpus = qMax(2, QThread::idealThreadCount() / 2);
    config.title = "Testux";
    m_qemu.start("qemu-system-x86_64", QemuArgs::build(config));
}

void Launcher::stop()
{
    m_qemu.terminate();
}
