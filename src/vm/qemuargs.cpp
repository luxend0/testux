#include "vm/qemuargs.h"

namespace {

// QEMU splits option values on ',' and reads ",," as a literal comma.
QString escaped(QString value)
{
    return value.replace(',', ",,");
}

QString acceleratorOption(const QString &accelerator)
{
    // WHPX misbehaves with the in-kernel irqchip on many Windows builds.
    if (accelerator == "whpx")
        return "whpx,kernel-irqchip=off";
    return accelerator == "kvm" ? "kvm" : "tcg";
}

// Under WHPX the guest sees the host CPUID no matter which model is chosen, so QEMU's
// default is left alone there. "host" needs KVM; "max" is the richest model TCG emulates.
QStringList cpuArgs(const QString &accelerator)
{
    if (accelerator == "kvm")
        return {"-cpu", "host"};
    if (accelerator == "whpx")
        return {};
    return {"-cpu", "max"};
}

QStringList machineArgs(const QemuConfig &config)
{
    QStringList args{"-name", escaped(config.title), "-nodefaults"};
    args << "-machine" << "q35";
    args << "-accel" << acceleratorOption(config.accelerator);
    args << cpuArgs(config.accelerator);
    args << "-m" << QString::number(config.ramMb);
    args << "-smp" << QString::number(config.cpus);
    if (!config.firmwarePath.isEmpty()) {
        args << "-drive"
             << "if=pflash,format=raw,unit=0,readonly=on,file=" + escaped(config.firmwarePath);
        if (!config.firmwareVarsPath.isEmpty()) {
            args << "-drive"
                 << "if=pflash,format=raw,unit=1,file=" + escaped(config.firmwareVarsPath);
        }
    }
    return args;
}

// The test disk boots first: while it is empty the firmware falls through to the ISO, and
// after a test install the VM starts the installed system with the ISO still attached.
QStringList storageArgs(const QemuConfig &config)
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

QStringList displayArgs(const QemuConfig &config)
{
    if (config.gl)
        return {"-device", "virtio-vga-gl", "-display", "gtk,gl=on,zoom-to-fit=on"};
    return {"-device", "virtio-vga", "-display", "gtk,zoom-to-fit=on"};
}

// QMP on a channel other local users cannot open (a TCP port would let anyone on the machine
// drive QEMU). The Windows pipe makes QEMU wait at startup until Testux connects.
QStringList qmpArgs(const QemuConfig &config)
{
    QString chardev;
    if (!config.qmpSocketPath.isEmpty())
        chardev = "socket,id=qmp,server=on,wait=off,path=" + escaped(config.qmpSocketPath);
    else if (!config.qmpPipeName.isEmpty())
        chardev = "pipe,id=qmp,path=" + escaped(config.qmpPipeName);
    else
        return {};
    return {"-chardev", chardev, "-mon", "chardev=qmp,mode=control"};
}

QStringList deviceArgs(const QemuConfig &config)
{
    QStringList args;
    // romfile= drops the PXE option ROM: nobody network boots a live ISO, and it would
    // add a boot delay plus a dependency on QEMU's iPXE blobs.
    args << "-netdev" << "user,id=net0";
    args << "-device" << "virtio-net-pci,netdev=net0,romfile=";
    args << "-device" << "qemu-xhci";
    args << "-device" << "usb-tablet";
    args << "-device" << "virtio-balloon-pci,id=balloon0,guest-stats-polling-interval=2";
    if (config.clipboard) {
        args << "-chardev" << "qemu-vdagent,id=vdagent,name=vdagent,clipboard=on";
        args << "-device" << "virtio-serial-pci";
        args << "-device" << "virtserialport,chardev=vdagent,name=com.redhat.spice.0";
    }
    if (!config.audioDriver.isEmpty()) {
        args << "-audiodev" << config.audioDriver + ",id=audio0";
        args << "-device" << "intel-hda";
        args << "-device" << "hda-duplex,audiodev=audio0";
    }
    return args;
}

} // namespace

QStringList QemuArgs::build(const QemuConfig &config)
{
    return machineArgs(config) + storageArgs(config) + displayArgs(config) + deviceArgs(config) +
           qmpArgs(config);
}
