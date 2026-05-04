import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control

    // "primary" for the one main action of a section, "secondary", "quiet" or "danger".
    property string kind: "secondary"

    readonly property bool primary: kind === "primary"

    horizontalPadding: kind === "quiet" ? Theme.gapM : 18
    verticalPadding: 9
    font.pixelSize: Theme.fontBase
    font.weight: Font.DemiBold
    opacity: enabled ? 1 : 0.45

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Label {
        text: control.text
        font: control.font
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: {
            if (control.primary)
                return Theme.accentText
            if (control.kind === "danger")
                return Theme.danger
            return control.kind === "quiet" ? Theme.accent : Theme.text
        }
    }

    background: Rectangle {
        implicitHeight: 38
        radius: Theme.radiusSmall
        color: {
            if (control.primary)
                return control.down || control.hovered ? Theme.accentHover : Theme.accent
            if (control.kind === "quiet")
                return control.hovered ? Theme.accentSoft : "transparent"
            if (control.kind === "danger")
                return control.hovered ? Theme.dangerSoft : Theme.surface
            return control.hovered ? Theme.surfaceMuted : Theme.surface
        }
        border.width: control.primary || control.kind === "quiet" ? 0 : 1
        border.color: control.kind === "danger" ? Qt.lighter(Theme.danger, 1.6) : Theme.borderStrong

        FocusRing {
            visible: control.visualFocus
        }
    }
}
