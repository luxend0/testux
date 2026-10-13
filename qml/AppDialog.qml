import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Centered modal with a title. Buttons placed in `actions` end up right-aligned below.
Dialog {
    id: dialog

    default property alias content: body.data
    property alias actions: actionRow.data

    parent: Overlay.overlay
    modal: true
    anchors.centerIn: parent
    width: Math.min(520, parent.width - 2 * Theme.gapXl)
    padding: Theme.gapXl
    topPadding: Theme.gapS

    background: Rectangle {
        color: Theme.surface
        radius: Theme.radiusLarge
        border.color: Theme.border
    }

    Overlay.modal: Rectangle {
        color: "#661b2330"
    }

    header: Label {
        text: dialog.title
        padding: Theme.gapXl
        bottomPadding: Theme.gapS
        font.pixelSize: Theme.fontTitle
        font.weight: Font.Bold
        wrapMode: Text.Wrap
    }

    ColumnLayout {
        id: body
        width: dialog.availableWidth
        spacing: Theme.gapL
    }

    footer: RowLayout {
        spacing: Theme.gapS

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: actionRow
            spacing: Theme.gapS
            Layout.margins: Theme.gapXl
            Layout.topMargin: 0
        }
    }
}
