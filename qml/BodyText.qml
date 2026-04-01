import QtQuick
import QtQuick.Controls.Basic

// Wrapping paragraph text. Give it a width, e.g. Layout.fillWidth.
Label {
    property bool muted: false

    color: muted ? Theme.textMuted : Theme.text
    wrapMode: Text.Wrap
    lineHeight: 1.15
}
