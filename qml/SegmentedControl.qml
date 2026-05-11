pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

// Row of mutually exclusive options, e.g. the category filter.
Rectangle {
    id: control

    // [{ value: string, label: string }]
    property var options: []
    property string current: ""

    signal picked(string value)

    implicitWidth: row.implicitWidth + 8
    implicitHeight: row.implicitHeight + 8
    radius: Theme.radius
    color: Theme.surfaceMuted
    border.color: Theme.border

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: control.options

            AbstractButton {
                id: option

                required property var modelData
                readonly property bool selected: modelData.value === control.current

                text: modelData.label
                horizontalPadding: Theme.gapL
                verticalPadding: 7
                onClicked: control.picked(modelData.value)

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                contentItem: Label {
                    text: option.text
                    font.weight: option.selected ? Font.DemiBold : Font.Normal
                    color: option.selected ? Theme.text : Theme.textMuted
                }

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: option.selected ? Theme.surface : (option.hovered ? "#eef1f5" : "transparent")
                    border.color: option.selected ? Theme.border : "transparent"

                    FocusRing {
                        visible: option.visualFocus
                    }
                }
            }
        }
    }
}
