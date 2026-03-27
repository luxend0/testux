pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: sidebar

    // [{ key: string, title: string }]
    property var sections: []
    property string current: ""

    signal picked(string key)

    readonly property VmSession session: VmManager.session
    readonly property bool sessionActive: session !== null
                                          && (session.state === VmSession.Starting || session.state === VmSession.Running)
}
