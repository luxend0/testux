#pragma once

#include <QString>
#include <QStringList>

// Everything that decides the QEMU command line. Host detection lives in VmManager;
// this stays a plain value so the argument building is testable.
struct QemuConfig
{
    QString isoPath;
    QString diskPath;         // qcow2 test disk, "" = none
    QString firmwarePath;     // UEFI code image (edk2-x86_64-code.fd), "" = SeaBIOS
    QString firmwareVarsPath; // writable UEFI vars matching the code image, "" = kept in RAM
    QString accelerator;      // "kvm", "whpx" or "tcg"
    QString audioDriver;      // -audiodev driver ("pipewire", "pa", "dsound"), "" = no audio
    int ramMb = 4096;
    int cpus = 2;
    // QMP endpoint only this user can reach: a unix socket path, or (Windows) the name of a
    // pipe QEMU creates as \\.\pipe\<name>. Both "" = no QMP.
    QString qmpSocketPath;
    QString qmpPipeName;
    bool gl = false;        // virtio-vga-gl + gtk,gl=on
    bool clipboard = false; // qemu-vdagent, only useful if QEMU's GTK UI has gtk_clipboard
    QString title;          // window title
};

namespace QemuArgs {

// Arguments for qemu-system-x86_64 (without the program itself). Always: q35, virtio
// display shown in QEMU's GTK window, user networking, virtio-balloon (id "balloon0")
// for RAM stats and, with `clipboard`, qemu-vdagent clipboard sharing.
QStringList build(const QemuConfig &config);

} // namespace QemuArgs
