import QtQuick

// Keyboard focus outline, placed inside a control's background.
Rectangle {
    property real baseRadius: Theme.radiusSmall

    anchors.fill: parent
    anchors.margins: -3
    radius: baseRadius + 3
    color: "transparent"
    border.width: 2
    border.color: Theme.focus
}
