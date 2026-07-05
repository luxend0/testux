import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Panel {
    id: panel

    required property distro distro

    signal setupRequested()
}
