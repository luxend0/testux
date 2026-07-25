pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// One line of the comparison table. The header row has no distro and is not clickable.
AbstractButton {
    id: row

    property bool header: false
    property list<var> columns
    property list<string> cells
    property distro distro
    property bool lastCellFaded: false
}
