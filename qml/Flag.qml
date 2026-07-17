import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// A small yes/no fact: green dot when on, hollow grey dot when off.
RowLayout {
    id: flag

    property alias text: label.text
    property bool on: false

    spacing: Theme.gapXs + 2

    StatusDot {
        filled: flag.on
        tint: flag.on ? Theme.ok : Theme.textFaint
        implicitWidth: 8
        implicitHeight: 8
    }

    Label {
        id: label
        font.pixelSize: Theme.fontSmall
        color: flag.on ? Theme.textMuted : Theme.textFaint
    }
}
