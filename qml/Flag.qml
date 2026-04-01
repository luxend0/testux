import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// A small yes/no fact: green dot when on, hollow grey dot when off.
RowLayout {
    id: flag

    spacing: Theme.gapXs + 2

    StatusDot {
        filled: flag.on
        tint: flag.on ? Theme.ok : Theme.textFaint
        implicitWidth: 8
        implicitHeight: 8
    }
}
