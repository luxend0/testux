pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: sidebar

    readonly property VmSession session: VmManager.session
    readonly property bool sessionActive: session !== null
                                          && (session.state === VmSession.Starting || session.state === VmSession.Running)
}
