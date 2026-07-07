pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Prepares a one-time boot into the live ISO, Windows only.
PageScroll {
    id: wizard

    required property distro distro

    signal backRequested()

    enum Step { Check, Space, Confirm, Prepare, Restart }

    property int step: BootWizard.Step.Check
    property bool makeRoom: true
    property bool backupConfirmed: false
    property int linuxSpaceGb: 40

    readonly property string name: Format.fullName(distro)
    readonly property int reservedGb: makeRoom ? linuxSpaceGb : 0
    readonly property IsoDownload download: IsoLibrary.iso(distro)
    readonly property list<checkResult> results: HardwareCheck.report.valid ? HardwareCheck.evaluate(distro, reservedGb) : []
    readonly property bool canBoot: HardwareCheck.report.valid && HardwareCheck.canBoot(distro, reservedGb)
    readonly property bool working: BareMetal.state === BareMetal.Working
    readonly property int shrinkGb: Math.ceil(HardwareCheck.requiredBytes(distro, reservedGb) / 1e9)

    maximumContentWidth: 820

    Connections {
        target: BareMetal

        function onStateChanged() {
            if (BareMetal.state === BareMetal.Working)
                wizard.step = BootWizard.Step.Prepare
            else if (BareMetal.state === BareMetal.ReadyToReboot)
                wizard.step = BootWizard.Step.Restart
        }
    }

    AppButton {
        kind: "quiet"
        text: qsTr("Back to %1").arg(wizard.name)
        enabled: !wizard.working
        onClicked: wizard.backRequested()
        Layout.leftMargin: -Theme.gapM
        Layout.bottomMargin: -Theme.gapM
    }

    PageHeader {
        title: qsTr("Boot %1 on this PC").arg(wizard.name)
        subtitle: qsTr("Your PC starts %1 once, straight from the hard drive. No USB stick needed.").arg(wizard.name)
    }

    StepIndicator {
        steps: [qsTr("Check"), qsTr("Space"), qsTr("Confirm"), qsTr("Prepare"), qsTr("Restart")]
        current: wizard.step
    }

    Component {
        id: confirmStep

        ColumnLayout {
            spacing: Theme.gapL

            Heading {
                text: qsTr("Before you start")
                Layout.fillWidth: true
            }

            DownloadPanel {
                distro: wizard.distro
                download: wizard.download
                Layout.fillWidth: true
            }

            FactList {
                labelWidth: 170
                facts: [
                    { label: qsTr("Drive C:"), value: wizard.makeRoom
                        ? qsTr("Shrinks by about %1 GB for the boot files and %2.").arg(wizard.shrinkGb).arg(wizard.name)
                        : qsTr("Shrinks by about %1 GB for the boot files.").arg(wizard.shrinkGb) },
                    { label: qsTr("Next restart"), value: qsTr("Starts %1 once. After that Windows starts as usual.").arg(wizard.name) },
                    { label: qsTr("BitLocker"), value: qsTr("Paused for that one restart if it is on. Keep your recovery key at hand anyway.") },
                    { label: qsTr("Undo"), value: qsTr("Back in Windows, Testux removes the boot files again.") }
                ]
                Layout.fillWidth: true
            }

            AppCheckBox {
                text: qsTr("I have a backup of my important files")
                detail: qsTr("Changing partitions is safe in almost every case. A backup covers the rest.")
                checked: wizard.backupConfirmed
                onToggled: wizard.backupConfirmed = checked
                Layout.fillWidth: true
            }
        }
    }
}
