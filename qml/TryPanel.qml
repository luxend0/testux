pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// "Try it in a window": download, then run in QEMU.
Panel {
    id: panel

    required property distro distro
}
