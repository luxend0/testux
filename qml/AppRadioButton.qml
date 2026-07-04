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
}
