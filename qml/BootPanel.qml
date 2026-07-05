import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Entry point to the bare-metal wizard on the distro page.
Panel {
    id: panel

    required property distro distro

    signal setupRequested()
}
