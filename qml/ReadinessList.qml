pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Traffic light lines from HardwareCheck.evaluate().
ColumnLayout {
    id: list

    property list<checkResult> results

    spacing: Theme.gapS

    Repeater {
        model: list.results

        Rectangle {
            id: line

            required property checkResult modelData

            implicitHeight: row.implicitHeight + 2 * Theme.gapM
            radius: Theme.radius
            color: modelData.level === "ok" ? Theme.surfaceMuted : Theme.levelSoftColor(modelData.level)
            Layout.fillWidth: true

            RowLayout {
                id: row
                spacing: Theme.gapM
                anchors {
                    fill: parent
                    margins: Theme.gapM
                    leftMargin: Theme.gapL
                }

                StatusDot {
                    tint: Theme.levelColor(line.modelData.level)
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 5
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Label {
                        text: line.modelData.title
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    BodyText {
                        text: line.modelData.detail
                        visible: text !== ""
                        muted: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
