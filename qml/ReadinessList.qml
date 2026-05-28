pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Traffic light lines from HardwareCheck.evaluate().
ColumnLayout {
    id: list

    property list<checkResult> results
}
