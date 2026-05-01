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

    implicitWidth: 208
    color: Theme.surface

    Rectangle {
        width: 1
        color: Theme.border
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
    }

    ColumnLayout {
        spacing: Theme.gapXs
        anchors {
            fill: parent
            margins: Theme.gapL
            topMargin: Theme.gapXl
        }

        RowLayout {
            spacing: Theme.gapM
            Layout.leftMargin: Theme.gapS
            Layout.bottomMargin: Theme.gapXl

            Image {
                source: "qrc:/qt/qml/Testux/assets/testux.svg"
                sourceSize: Qt.size(32, 32)
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
            }

            Label {
                text: "Testux"
                font.pixelSize: Theme.fontTitle
                font.weight: Font.Bold
            }
        }

        Repeater {
            model: sidebar.sections

            NavItem {
                required property var modelData

                text: modelData.title
                current: modelData.key === sidebar.current
                onClicked: sidebar.picked(modelData.key)
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            visible: sidebar.sessionActive
            implicitHeight: running.implicitHeight + 2 * Theme.gapM
            radius: Theme.radius
            color: Theme.okSoft
            Layout.fillWidth: true

            ColumnLayout {
                id: running
                spacing: Theme.gapS
                anchors {
                    fill: parent
                    margins: Theme.gapM
                }

                Label {
                    text: sidebar.sessionActive ? qsTr("Running: %1").arg(Catalog.distro(sidebar.session.distroId).name) : ""
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                AppButton {
                    text: qsTr("Stop")
                    onClicked: sidebar.session.stop()
                    Layout.fillWidth: true
                }
            }
        }

        Label {
            text: qsTr("Version %1").arg(Qt.application.version)
            color: Theme.textFaint
            font.pixelSize: Theme.fontSmall
            Layout.leftMargin: Theme.gapS
            Layout.topMargin: Theme.gapS
        }
    }
}
