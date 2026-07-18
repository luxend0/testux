import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Dialog {
    id: dialog

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
