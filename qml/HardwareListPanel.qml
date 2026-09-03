pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// A titled list of devices with an optional hint below.
Panel {
    id: panel

    property string title
    property list<string> entries
    property string hint

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.gapM

        Heading {
            text: panel.title
            Layout.fillWidth: true
        }

        Repeater {
            model: panel.entries

            Label {
                required property string modelData

                text: modelData
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }

        Label {
            visible: panel.entries.length === 0
            text: qsTr("None found")
            color: Theme.textFaint
        }

        Notice {
            kind: "warning"
            visible: panel.hint !== ""
            text: panel.hint
            Layout.fillWidth: true
        }
    }
}
