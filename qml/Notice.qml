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

    Rectangle {
        width: 4
        radius: 2
        color: notice.tint
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: Theme.gapM
        }
    }

    ColumnLayout {
        id: column
        spacing: Theme.gapXs
        anchors {
            fill: parent
            margins: Theme.gapL
            leftMargin: Theme.gapL + Theme.gapM
        }

        Label {
            id: titleLabel
            Layout.fillWidth: true
            visible: text !== ""
            font.weight: Font.DemiBold
            color: Theme.text
            wrapMode: Text.Wrap
        }

        BodyText {
            id: textLabel
            Layout.fillWidth: true
            visible: text !== ""
            muted: true
        }

        RowLayout {
            id: actionRow
            visible: children.length > 0
            spacing: Theme.gapS
            Layout.topMargin: Theme.gapXs
        }
    }
}
