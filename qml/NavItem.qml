import QtQuick
import QtQuick.Controls.Basic

AbstractButton {
    id: item

    property bool current: false

    padding: Theme.gapM
    leftPadding: Theme.gapL
    implicitHeight: 40

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: item.current ? Theme.accentSoft : (item.hovered ? Theme.surfaceMuted : "transparent")

        FocusRing {
            visible: item.visualFocus
        }
    }
}
