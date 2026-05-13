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
}
