pragma Singleton

import QtQuick

// Colors, spacing and type sizes for the whole app. Light and calm on purpose: Testux is
// often the first Linux contact for people coming from Windows.
QtObject {
    readonly property color background: "#f3f5f8"
    readonly property color surface: "#ffffff"
    readonly property color surfaceMuted: "#f7f8fa"
    readonly property color border: "#e1e5eb"
    readonly property color borderStrong: "#c9d0da"

    readonly property color text: "#1b2330"
    readonly property color textMuted: "#5a6474"
    readonly property color textFaint: "#8a93a2"

    readonly property color accent: "#2f6fde"
    readonly property color accentHover: "#275fc2"
    readonly property color accentSoft: "#e8effc"
    readonly property color accentText: "#ffffff"
    readonly property color focus: "#86a9ee"
}
