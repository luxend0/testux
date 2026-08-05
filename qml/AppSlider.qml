import QtQuick
import QtQuick.Controls.Basic

Slider {
    id: control

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: 3
        color: Theme.border

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: Theme.accent
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 22
        implicitHeight: 22
        radius: 11
        color: Theme.surface
        border.width: 2
        border.color: Theme.accent

        FocusRing {
            baseRadius: 11
            visible: control.visualFocus
        }
    }
}
