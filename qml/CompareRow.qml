pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

AbstractButton {
    id: row

    property bool header: false
    property list<var> columns
    property list<string> cells
    property distro distro
    property bool lastCellFaded: false
}
