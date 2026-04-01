import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    property alias title: titleLabel.text
    property alias subtitle: subtitleLabel.text

    Label {
        id: titleLabel
        font.pixelSize: Theme.fontHeadline
        font.weight: Font.Bold
        color: Theme.text
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }
}
