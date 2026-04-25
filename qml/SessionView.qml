import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Live state of the VM running this distro.
Rectangle {
    id: view

    required property VmSession session
    required property string distroName
}
