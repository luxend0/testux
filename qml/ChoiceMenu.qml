pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// Single choice from a popup list, e.g. "Category: Gaming".
MenuButton {
    id: menu

    property string title
    // [{ value: string, label: string }]
    property list<var> options
    property string current
    // Value that counts as "nothing chosen", shown without highlight.
    property string neutralValue: ""

    signal picked(string value)

    readonly property string currentLabel: options.find(option => option.value === current)?.label ?? ""

    text: qsTr("%1: %2").arg(title).arg(currentLabel)
    optionCount: options.length
    highlighted: current !== neutralValue

    Repeater {
        model: menu.options

        AppRadioButton {
            id: option

            required property var modelData

            text: modelData.label
            checked: modelData.value === menu.current
            onClicked: {
                menu.picked(modelData.value)
                menu.closeMenu()
            }
            onActiveFocusChanged: if (activeFocus) menu.revealItem(option)
            Layout.minimumWidth: 180
        }
    }
}
