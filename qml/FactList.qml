pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: list

    Repeater {
        model: list.facts

        ColumnLayout {
            id: row

            required property var modelData
            required property int index

            spacing: 0
            Layout.fillWidth: true

            Rectangle {
                visible: row.index > 0
                color: Theme.border
                implicitHeight: 1
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapL
                Layout.topMargin: Theme.gapS + 2
                Layout.bottomMargin: Theme.gapS + 2

                Label {
                    text: row.modelData.label
                    color: Theme.textMuted
                    wrapMode: Text.Wrap
                    Layout.preferredWidth: list.labelWidth
                    Layout.alignment: Qt.AlignTop
                }

                Label {
                    text: row.modelData.value
                    color: Theme.text
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }
    }
}
