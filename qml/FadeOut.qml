import QtQuick

Transition {
    NumberAnimation {
        property: "opacity"
        from: 1
        to: 0
        duration: 120
        easing.type: Easing.InCubic
    }
}
