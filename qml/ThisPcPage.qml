import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
    id: page

    readonly property hardwareReport report: HardwareCheck.report

    maximumContentWidth: 900

    PageHeader {
        title: qsTr("This PC")
        subtitle: qsTr("What Testux found out about your hardware. None of it leaves your PC.")
    }

    RowLayout {
        visible: HardwareCheck.busy || !page.report.valid
        spacing: Theme.gapM

        BusyIndicator {
            running: visible
            implicitWidth: 28
            implicitHeight: 28
        }

        Label {
            text: qsTr("Checking your PC")
            color: Theme.textMuted
        }
    }

    Panel {
        visible: page.report.valid
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gapM

            RowLayout {
                Layout.fillWidth: true

                Heading {
                    text: qsTr("System")
                    Layout.fillWidth: true
                }

                AppButton {
                    kind: "quiet"
                    text: qsTr("Check again")
                    enabled: !HardwareCheck.busy
                    onClicked: HardwareCheck.run()
                }
            }

            FactList {
                labelWidth: 240
                facts: {
                    const r = page.report
                    const rows = [
                        { label: qsTr("Memory"), value: Format.megabytes(r.ramMb) },
                        { label: qsTr("Processor threads"), value: String(r.cpuThreads) },
                        { label: qsTr("Free space on the system drive"), value: Format.bytes(r.systemFreeBytes) },
                        { label: qsTr("Fast virtual machines"), value: r.virtualization ? qsTr("Available") : qsTr("Not available, VMs run slowly") },
                        { label: qsTr("Boot mode"), value: r.uefi ? qsTr("UEFI") : qsTr("Legacy BIOS") },
                        { label: qsTr("Secure Boot"), value: r.secureBoot ? qsTr("On") : qsTr("Off") }
                    ]
                    if (r.windows) {
                        rows.push({ label: qsTr("Partition style"), value: r.gptSystemDisk ? qsTr("GPT") : qsTr("MBR") })
                        rows.push({ label: qsTr("BitLocker"), value: r.bitLocker ? qsTr("On") : qsTr("Off") })
                        rows.push({ label: qsTr("Fast Startup"), value: r.fastStartup ? qsTr("On") : qsTr("Off") })
                    }
                    return rows
                }
                Layout.fillWidth: true
            }
        }
    }

    HardwareListPanel {
        visible: page.report.valid
        title: qsTr("Graphics")
        entries: page.report.gpus
        hint: page.report.nvidiaGpu
              ? qsTr("NVIDIA cards work best with the proprietary driver. Distros marked \"NVIDIA driver included\" set it up for you, on the others you install it after setup.")
              : ""
        Layout.fillWidth: true
    }

    HardwareListPanel {
        visible: page.report.valid
        title: qsTr("Wi-Fi")
        entries: page.report.wifiAdapters
        hint: page.report.broadcomWifi
              ? qsTr("Broadcom Wi-Fi often needs an extra driver on Linux. Keep a network cable or phone tethering ready for the first start.")
              : ""
        Layout.fillWidth: true
    }
}
