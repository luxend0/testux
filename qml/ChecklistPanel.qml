pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Shared plus distro specific "try this" list. Ticks are remembered per distro.
Panel {
    id: panel

    required property distro distro

    readonly property list<checklistItem> items: [...Catalog.checklist, ...distro.checklist]
    property list<string> done

    Component.onCompleted: done = JSON.parse(store.value(distro.id, "[]"))

    function setDone(itemId: string, checked: bool) {
        const next = done.filter(id => id !== itemId)
        if (checked)
            next.push(itemId)
        done = next
        store.setValue(distro.id, JSON.stringify(next))
    }

    Settings {
        id: store
        category: "checklist"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.gapL

        RowLayout {
            Layout.fillWidth: true

            Heading {
                text: qsTr("Things to try")
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("%1 of %2").arg(panel.items.filter(item => panel.done.includes(item.id)).length).arg(panel.items.length)
                color: Theme.textFaint
            }
        }

        Repeater {
            model: panel.items

            AppCheckBox {
                required property checklistItem modelData

                text: modelData.title
                detail: modelData.detail
                checked: panel.done.includes(modelData.id)
                onToggled: panel.setDone(modelData.id, checked)
                Layout.fillWidth: true
            }
        }
    }
}
