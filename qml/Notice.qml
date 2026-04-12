import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Tinted message box. Buttons placed inside end up in a row under the text.
Rectangle {
    id: notice

    property string kind: "info" // "info", "ok", "warning" or "error"
    property alias title: titleLabel.text
    property alias text: textLabel.text
    default property alias actions: actionRow.data

    readonly property color tint: {
        switch (kind) {
        case "ok": return Theme.ok
        case "warning": return Theme.warning
        case "error": return Theme.danger
        default: return Theme.accent
        }
    }
}
