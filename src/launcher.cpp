#include "launcher.h"

#include "vm/qemuargs.h"

Launcher::Launcher(QObject *parent)
    : QObject(parent)
{
}

void Launcher::start(const QString &isoPath)
{
    QemuConfig config;
    config.isoPath = isoPath;
    config.accelerator = "kvm";
    config.ramMb = 4096;
    config.cpus = 4;
    config.title = "Testux";
    m_qemu.start("qemu-system-x86_64", QemuArgs::build(config));
}
