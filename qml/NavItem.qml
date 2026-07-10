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

    contentItem: Label {
        text: item.text
        verticalAlignment: Text.AlignVCenter
        font.weight: item.current ? Font.DemiBold : Font.Normal
        color: item.current ? Theme.accent : Theme.text
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: item.current ? Theme.accentSoft : (item.hovered ? Theme.surfaceMuted : "transparent")

        FocusRing {
            visible: item.visualFocus
        }
    }
}
