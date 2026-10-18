import QtQuick
import QtQuick.Controls.Basic

// Compact on/off filter.
AbstractButton {
    id: chip

    checkable: true
    horizontalPadding: Theme.gapM + 2
    implicitHeight: 38
    implicitWidth: implicitContentWidth + leftPadding + rightPadding

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Label {
        text: chip.text
        verticalAlignment: Text.AlignVCenter
        font.weight: chip.checked ? Font.DemiBold : Font.Normal
        color: chip.checked ? Theme.accent : Theme.textMuted
    }

    background: Rectangle {
        radius: Theme.radius
        color: chip.checked ? Theme.accentSoft : (chip.hovered ? Theme.surfaceMuted : Theme.surface)
        border.color: chip.checked ? Theme.accent : Theme.border

        FocusRing {
            baseRadius: Theme.radius
            visible: chip.visualFocus
        }
    }
}
