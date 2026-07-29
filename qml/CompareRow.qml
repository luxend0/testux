pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// One line of the comparison table. The header row has no distro and is not clickable.
AbstractButton {
    id: row

    property bool header: false
    property list<var> columns
    property list<string> cells
    property distro distro
    property bool lastCellFaded: false

    HoverHandler {
        enabled: !row.header
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        color: row.header ? Theme.surfaceMuted : (row.hovered ? "#f9fafc" : "transparent")
        radius: row.header ? Theme.radiusLarge : 0

        Rectangle {
            visible: row.header
            color: parent.color
            height: parent.radius
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }

        Rectangle {
            height: 1
            color: Theme.border
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }

        FocusRing {
            visible: row.visualFocus
        }
    }
}
