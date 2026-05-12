import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text

    spacing: Theme.gapXs
    Layout.fillWidth: true

    Label {
        id: titleLabel
        font.pixelSize: Theme.fontHeadline
        font.weight: Font.Bold
        color: Theme.text
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    BodyText {
        id: subtitleLabel
        visible: text !== ""
        muted: true
        font.pixelSize: Theme.fontLarge - 1
        Layout.fillWidth: true
    }
}
