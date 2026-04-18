import QtQuick

Rectangle {
    property bool filled: true
    property color tint: Theme.ok

    implicitWidth: 10
    implicitHeight: 10
    radius: width / 2
    color: filled ? tint : "transparent"
    border.width: filled ? 0 : 1.5
    border.color: tint
}
