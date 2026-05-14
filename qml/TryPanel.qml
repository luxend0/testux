pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// "Try it in a window": download, then run in QEMU.
Panel {
    id: panel

    required property distro distro

    readonly property IsoDownload download: IsoLibrary.iso(distro)
    readonly property VmSession session: VmManager.session
    readonly property bool sessionHere: session !== null && session.distroId === distro.id
    readonly property bool active: sessionHere
                                   && (session.state === VmSession.Starting || session.state === VmSession.Running)
    readonly property bool otherActive: session !== null && !sessionHere
                                        && (session.state === VmSession.Starting || session.state === VmSession.Running)

    // hasTestDisk() does not notify, so the binding re-evaluates on this counter.
    property int diskRevision: 0
    readonly property bool hasTestDisk: diskRevision >= 0 && VmManager.hasTestDisk(distro.id)
}
