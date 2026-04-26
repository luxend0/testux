import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Live state of the VM running this distro.
Rectangle {
    id: view

    required property VmSession session
    required property string distroName

    readonly property bool running: session.state === VmSession.Running
    property bool stopping: false

    implicitHeight: column.implicitHeight + 2 * Theme.gapL
    radius: Theme.radius
    color: Theme.surfaceMuted
    border.color: Theme.border
}
