import QtQuick

Transition {
    NumberAnimation {
        property: "opacity"
        from: 0
        to: 1
        duration: 160
        easing.type: Easing.OutCubic
    }
}
