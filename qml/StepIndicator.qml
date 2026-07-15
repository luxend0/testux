pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

RowLayout {
    id: indicator

    property list<string> steps
    property int current: 0

    spacing: Theme.gapS

    Repeater {
        model: indicator.steps

        RowLayout {
            id: step

            required property string modelData
            required property int index
            readonly property bool reached: index <= indicator.current

            spacing: Theme.gapS

            Rectangle {
                visible: step.index > 0
                implicitWidth: 28
                implicitHeight: 2
                color: step.reached ? Theme.accent : Theme.border
            }

            Rectangle {
                implicitWidth: 26
                implicitHeight: 26
                radius: 13
                color: step.index === indicator.current ? Theme.accent : (step.reached ? Theme.accentSoft : Theme.surface)
                border.width: step.reached ? 0 : 1.5
                border.color: Theme.borderStrong

                Label {
                    anchors.centerIn: parent
                    text: step.index + 1
                    font.pixelSize: Theme.fontSmall
                    font.weight: Font.DemiBold
                    color: step.index === indicator.current ? Theme.accentText : (step.reached ? Theme.accent : Theme.textFaint)
                }
            }

            Label {
                text: step.modelData
                font.weight: step.index === indicator.current ? Font.DemiBold : Font.Normal
                color: step.reached ? Theme.text : Theme.textFaint
            }
        }
    }
}
