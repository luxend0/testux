import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: dialog

    parent: Overlay.overlay
    modal: true
    anchors.centerIn: parent
    width: Math.min(520, parent.width - 2 * Theme.gapXl)
    padding: Theme.gapXl
    topPadding: Theme.gapS

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
}
