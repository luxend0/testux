#include "launcher.h"

Launcher::Launcher(QObject *parent)
    : QObject(parent)
{
}

void Launcher::start(const QString &isoPath)
{
    const QStringList args = {
        "-enable-kvm", "-m", "4096", "-smp", "4",
        "-cdrom", isoPath,
        "-vga", "virtio",
        "-display", "gtk",
    };
    m_qemu.start("qemu-system-x86_64", args);
}
