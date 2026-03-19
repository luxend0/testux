import QtQuick
import QtQuick.Controls.Basic

// A tile in the distro color with the name's initial.
Rectangle {
    id: tile

    required property string name
    property string tint: ""
    property int size: 48

    implicitWidth: size
    implicitHeight: size
    radius: Math.round(size * 0.28)
    color: tint !== "" ? tint : Theme.accent

    Label {
        anchors.centerIn: parent
        text: tile.name.charAt(0).toUpperCase()
        color: Theme.textOn(tile.color)
        font.pixelSize: Math.round(tile.size * 0.46)
        font.weight: Font.Bold
    }
}
