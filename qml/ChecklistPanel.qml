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
}
