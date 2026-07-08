import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Entry point to the bare-metal wizard on the distro page.
Panel {
    id: panel

    required property distro distro

    signal setupRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.gapL

        ColumnLayout {
            spacing: Theme.gapXs
            Layout.fillWidth: true

            Heading {
                text: qsTr("Boot it on this PC")
                Layout.fillWidth: true
            }

            BodyText {
                text: qsTr("Starts %1 directly on your hardware, without a USB stick. It runs at full speed and you can install it from there. Windows stays and starts as usual afterwards.").arg(panel.distro.name)
                muted: true
                Layout.fillWidth: true
            }
        }

        BodyText {
            visible: !BareMetal.supported
            text: qsTr("This works on Windows PCs for now.")
            muted: true
            Layout.fillWidth: true
        }

        RowLayout {
            visible: BareMetal.supported
            spacing: Theme.gapM
            Layout.fillWidth: true

            StatusDot {
                visible: HardwareCheck.report.valid
                tint: Theme.levelColor(panel.blockers > 0 ? "blocker" : (panel.warnings > 0 ? "warning" : "ok"))
            }

            Label {
                text: {
                    if (!HardwareCheck.report.valid)
                        return qsTr("Checking your PC")
                    if (panel.windowOnly)
                        return qsTr("This distro can only be tried in a window")
                    if (panel.blockers > 0)
                        return qsTr("Not ready yet, see what to change")
                    if (panel.warnings > 0)
                        return qsTr("Ready, with a few things to know")
                    return qsTr("Your PC is ready")
                }
                color: Theme.textMuted
                Layout.fillWidth: true
            }

            AppButton {
                text: qsTr("Set up boot")
                onClicked: panel.setupRequested()
            }
        }
    }
}
