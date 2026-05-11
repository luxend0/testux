import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Live state of the VM running this distro.
Rectangle {
    id: view

    required property VmSession session
    required property string distroName

    readonly property bool running: session.state === VmSession.Running
    // The guest gets up to 20 s to shut down on its own, show that something is happening.
    property bool stopping: false

    implicitHeight: column.implicitHeight + 2 * Theme.gapL
    radius: Theme.radius
    color: Theme.surfaceMuted
    border.color: Theme.border

    ColumnLayout {
        id: column
        spacing: Theme.gapM
        anchors {
            fill: parent
            margins: Theme.gapL
        }

        RowLayout {
            spacing: Theme.gapS
            Layout.fillWidth: true

            StatusDot {
                tint: view.running && !view.stopping ? Theme.ok : Theme.warning
            }

            Label {
                text: view.stopping
                      ? qsTr("Shutting down %1").arg(view.distroName)
                      : view.running
                        ? qsTr("%1 is running in its own window").arg(view.distroName)
                        : qsTr("Starting %1").arg(view.distroName)
                font.weight: Font.DemiBold
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            AppButton {
                text: qsTr("Stop")
                enabled: !view.stopping
                onClicked: {
                    view.stopping = true
                    view.session.stop()
                }
            }
        }

        ColumnLayout {
            spacing: Theme.gapXs
            visible: view.session.guestRamTotalMb > 0
            Layout.fillWidth: true

            Label {
                text: qsTr("Uses %1 of %2 memory").arg(Format.megabytes(view.session.guestRamUsedMb)).arg(Format.megabytes(view.session.guestRamTotalMb))
                color: Theme.textMuted
            }

            AppProgressBar {
                value: view.session.guestRamUsedMb / view.session.guestRamTotalMb
                Layout.fillWidth: true
            }
        }

        BodyText {
            visible: view.session.guestRamTotalMb === 0
            text: qsTr("Memory use shows up once the system has booted.")
            muted: true
            Layout.fillWidth: true
        }
    }
}
