import QtQuick
import QtQuick.Controls.Basic

Rectangle {
    id: tile

    required property string name
    property string tint: ""
    property url logo
    property int size: 48

    readonly property bool showLogo: image.status === Image.Ready

    implicitWidth: size
    implicitHeight: size
    radius: Math.round(size * 0.28)
    color: showLogo ? Theme.surface : tint !== "" ? tint : Theme.accent
    border.width: showLogo ? 1 : 0
    border.color: Theme.border

    Image {
        id: image

        anchors.fill: parent
        anchors.margins: Math.round(tile.size * 0.16)
        source: tile.logo
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        visible: tile.showLogo
    }

    Label {
        anchors.centerIn: parent
        visible: !tile.showLogo
        text: tile.name.charAt(0).toUpperCase()
        color: Theme.textOn(tile.color)
        font.pixelSize: Math.round(tile.size * 0.46)
        font.weight: Font.Bold
    }
}
