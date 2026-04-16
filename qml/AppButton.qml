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
}
