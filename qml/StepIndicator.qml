pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

RowLayout {
    id: indicator

    property list<string> steps
    property int current: 0

    spacing: Theme.gapS
}
