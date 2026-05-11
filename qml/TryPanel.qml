pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// "Try it in a window": download, then run in QEMU.
Panel {
    id: panel

    required property distro distro

    readonly property IsoDownload download: IsoLibrary.iso(distro)
    readonly property VmSession session: VmManager.session
    readonly property bool sessionHere: session !== null && session.distroId === distro.id
    readonly property bool active: sessionHere
                                   && (session.state === VmSession.Starting || session.state === VmSession.Running)
    readonly property bool otherActive: session !== null && !sessionHere
                                        && (session.state === VmSession.Starting || session.state === VmSession.Running)

    // hasTestDisk() does not notify, so the binding re-evaluates on this counter.
    property int diskRevision: 0
    readonly property bool hasTestDisk: diskRevision >= 0 && VmManager.hasTestDisk(distro.id)

    Connections {
        target: VmManager

        function onTestDisksChanged() {
            ++panel.diskRevision
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.gapL

        ColumnLayout {
            spacing: Theme.gapXs
            Layout.fillWidth: true

            Heading {
                text: qsTr("Try it in a window")
                Layout.fillWidth: true
            }

            BodyText {
                text: qsTr("%1 runs in a window next to your apps. Your PC stays exactly as it is.").arg(panel.distro.name)
                muted: true
                Layout.fillWidth: true
            }
        }

        Notice {
            kind: "error"
            visible: !VmManager.available
            title: qsTr("QEMU is missing")
            text: VmManager.setupHint
            Layout.fillWidth: true
        }

        Notice {
            kind: "warning"
            visible: VmManager.available && VmManager.setupHint !== ""
            title: qsTr("This will run slowly")
            text: VmManager.setupHint
            Layout.fillWidth: true
        }

        Notice {
            visible: !panel.distro.liveSession
            text: qsTr("%1 has no live desktop. The window opens its installer, so use a test disk to see the system.").arg(panel.distro.name)
            Layout.fillWidth: true
        }

        DownloadPanel {
            distro: panel.distro
            download: panel.download
            Layout.fillWidth: true
        }

        Loader {
            active: panel.active
            visible: active
            Layout.fillWidth: true

            sourceComponent: SessionView {
                session: panel.session
                distroName: panel.distro.name
            }
        }

        Notice {
            kind: "error"
            visible: panel.sessionHere && panel.session.state === VmSession.Failed
            title: qsTr("The VM stopped with an error")
            text: panel.sessionHere ? panel.session.error : ""
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: Theme.gapM
            visible: !panel.active
            Layout.fillWidth: true

            AppCheckBox {
                id: useDisk
                checked: panel.hasTestDisk
                text: panel.hasTestDisk ? qsTr("Use my test disk") : qsTr("Add a test disk")
                detail: panel.hasTestDisk
                        ? qsTr("Your test install from last time is kept.")
                        : qsTr("Lets you run the installer for a real test install. Takes up to 30 GB, only what is used.")
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapS
                Layout.fillWidth: true

                AppButton {
                    kind: "primary"
                    text: qsTr("Start in a window")
                    enabled: VmManager.available && panel.download.state === IsoDownload.Ready
                    onClicked: VmManager.start(panel.distro, panel.download.path, useDisk.checked)
                }

                AppButton {
                    kind: "quiet"
                    visible: panel.hasTestDisk
                    text: qsTr("Delete test disk")
                    onClicked: VmManager.removeTestDisk(panel.distro.id)
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            BodyText {
                visible: panel.otherActive
                text: qsTr("Another distro is running. Starting this one stops it first.")
                muted: true
                font.pixelSize: Theme.fontSmall
                Layout.fillWidth: true
            }
        }
    }
}
