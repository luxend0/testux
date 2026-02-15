#include "vm/qemuargs.h"

namespace {

// QEMU splits option values on ',' and reads ",," as a literal comma.
QString escaped(QString value)
{
    qDebug() << Q_FUNC_INFO;
    return value.replace(',', ",,");
}

QString acceleratorOption(const QString& accelerator)
{
    if (accelerator == "whpx")
        return "whpx,kernel-irqchip=off";
    return accelerator == "kvm" ? "kvm" : "tcg";
}

// Under WHPX the guest sees the host CPUID no matter which model is chosen, so QEMU's
// default is left alone there. "host" needs KVM; "max" is the richest model TCG emulates.
QStringList cpuArgs(const QString& accelerator)
{
    if (accelerator == "kvm")
        return {"-cpu", "host"};
    if (accelerator == "whpx")
        return {};
    return {"-cpu", "max"};
}

// The test disk boots first: while it is empty the firmware falls through to the ISO, and
// after a test install the VM starts the installed system with the ISO still attached.
QStringList storageArgs(const QemuConfig& config)
{
    const bool hasDisk = !config.diskPath.isEmpty();
    QStringList args;
    if (hasDisk) {
        args << "-drive"
             << "if=none,id=disk0,format=qcow2,discard=unmap,file=" + escaped(config.diskPath);
        args << "-device" << "virtio-blk-pci,drive=disk0,bootindex=0";
    }
    args << "-drive" << "if=none,id=cd0,media=cdrom,readonly=on,file=" + escaped(config.isoPath);
    args << "-device" << QString("ide-cd,drive=cd0,bootindex=%1").arg(hasDisk ? 1 : 0);
    return args;
}

} // namespace
