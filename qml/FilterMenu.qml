pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// Multi-select filter, e.g. "Desktop (2)".
MenuButton {
    id: menu

    property string title
    // [{ value: string, label: string }]
    property list<var> options
    property list<string> selected

    signal optionToggled(string value, bool on)

    text: selected.length > 0 ? qsTr("%1 (%2)").arg(title).arg(selected.length) : title
    optionCount: options.length
    highlighted: selected.length > 0

    Repeater {
        model: menu.options

        AppCheckBox {
            id: option

            required property var modelData

            text: modelData.label
            checked: menu.selected.includes(modelData.value)
            onToggled: menu.optionToggled(modelData.value, checked)
            onActiveFocusChanged: if (activeFocus) menu.revealItem(option)
            Layout.minimumWidth: 180
        }
    }
}
