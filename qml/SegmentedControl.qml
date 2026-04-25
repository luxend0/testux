pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

// Row of mutually exclusive options, e.g. the category filter.
Rectangle {
    id: control

    // [{ value: string, label: string }]
    property var options: []
    property string current: ""
}
