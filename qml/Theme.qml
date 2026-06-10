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

    readonly property color ok: "#2e8a57"
    readonly property color okSoft: "#e6f4ec"
    readonly property color warning: "#a8670f"
    readonly property color warningSoft: "#fdf3e1"
    readonly property color danger: "#c0433d"
    readonly property color dangerSoft: "#fbeaea"

    readonly property int radiusSmall: 8
    readonly property int radius: 12
    readonly property int radiusLarge: 16

    readonly property int gapXs: 4
    readonly property int gapS: 8
    readonly property int gapM: 12
    readonly property int gapL: 16
    readonly property int gapXl: 24
    readonly property int gapXxl: 32

    readonly property int fontSmall: 12
    readonly property int fontBase: 14
    readonly property int fontLarge: 16
    readonly property int fontTitle: 20
    readonly property int fontHeadline: 26

    // "ok", "warning" and "blcoker" as used by checkResult.level.
    function levelColor(level: string): color {
        if (level === "blocker")
            return danger
        return level === "warning" ? warning : ok
    }

    function levelSoftColor(level: string): color {
        if (level === "blocker")
            return dangerSoft
        return level === "warning" ? warningSoft : okSoft
    }
}
