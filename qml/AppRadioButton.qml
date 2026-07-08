import QtQuick
import QtQuick.Controls.Basic

// Radio button with an optional second line of explanation.
RadioButton {
    id: control

    property string detail: ""

    spacing: Theme.gapM
    padding: 0

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: control.topPadding + 1
        radius: 10
        color: Theme.surface
        border.width: control.checked ? 6 : 1.5
        border.color: control.checked || control.hovered ? Theme.accent : Theme.borderStrong

        FocusRing {
            baseRadius: 10
            visible: control.visualFocus
        }
    }

    contentItem: Column {
        leftPadding: control.indicator.width + control.spacing
        spacing: 2

        Label {
            width: parent.width - parent.leftPadding
            text: control.text
            font.weight: control.detail !== "" ? Font.DemiBold : Font.Normal
            wrapMode: Text.Wrap
        }

        BodyText {
            width: parent.width - parent.leftPadding
            visible: control.detail !== ""
            text: control.detail
            muted: true
            font.pixelSize: Theme.fontBase - 1
        }
    }
}
