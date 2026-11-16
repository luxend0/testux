pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

// "Try it in a window": one button that downloads once and then starts QEMU by itself.
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

    // Set by "Try it" while the download still runs; the VM starts as soon as it is ready.
    property bool startWhenReady: false
    readonly property bool downloading: download.state === IsoDownload.Downloading || download.state === IsoDownload.Verifying

    function startVm() {
        startWhenReady = false
        VmManager.start(distro, download.path, useDisk.checked)
    }

    function tryIt() {
        if (download.state === IsoDownload.Ready) {
            startVm()
        } else {
            startWhenReady = true
            if (!downloading)
                download.start()
        }
    }

    Connections {
        target: panel.download

        function onStateChanged() {
            if (panel.download.state === IsoDownload.Ready && panel.startWhenReady)
                panel.startVm()
            else if (panel.download.state === IsoDownload.Failed || panel.download.state === IsoDownload.Missing)
                panel.startWhenReady = false
        }
    }

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
                text: qsTr("%1 opens in its own window next to your apps. Nothing on your PC changes, close the window when you are done.").arg(panel.distro.name)
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
            kind: VmManager.fastModeError !== "" ? "error" : "warning"
            visible: VmManager.available && VmManager.setupHint !== ""
            title: VmManager.restartPending ? qsTr("Restart Windows for fast mode") : qsTr("This will run slowly")
            text: VmManager.fastModeError !== "" ? VmManager.fastModeError : VmManager.setupHint
            Layout.fillWidth: true

            AppButton {
                visible: VmManager.canEnableFastMode
                enabled: !VmManager.enablingFastMode
                text: VmManager.enablingFastMode ? qsTr("Turning on fast mode") : qsTr("Turn on fast mode")
                onClicked: VmManager.enableFastMode()
            }
        }

        Notice {
            visible: !panel.distro.liveSession
            text: qsTr("%1 cannot be tried without installing. The window opens its installer, so turn on \"Keep a test install\" below to see the system.").arg(panel.distro.name)
            Layout.fillWidth: true
        }

        DownloadPanel {
            visible: panel.download.state !== IsoDownload.Missing
            distro: panel.distro
            download: panel.download
            Layout.fillWidth: true
        }

        BodyText {
            visible: panel.downloading && panel.startWhenReady
            text: qsTr("%1 opens by itself when the download is done.").arg(panel.distro.name)
            muted: true
            font.pixelSize: Theme.fontSmall
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

            RowLayout {
                spacing: Theme.gapM
                Layout.fillWidth: true

                AppButton {
                    kind: "primary"
                    text: panel.download.state === IsoDownload.Ready ? qsTr("Try it in a window") : qsTr("Try it")
                    enabled: VmManager.available && !(panel.downloading && panel.startWhenReady)
                    onClicked: panel.tryIt()
                }

                BodyText {
                    visible: panel.download.state === IsoDownload.Missing
                    text: panel.download.received > 0
                          ? qsTr("Download paused at %1 of %2.").arg(Format.bytes(panel.download.received)).arg(Format.bytes(panel.distro.isoSize))
                          : qsTr("Downloads %1 once and checks it, then it starts.").arg(Format.bytes(panel.distro.isoSize))
                    muted: true
                    font.pixelSize: Theme.fontSmall
                    Layout.fillWidth: true
                }
            }

            AppCheckBox {
                id: useDisk
                checked: panel.hasTestDisk
                text: panel.hasTestDisk ? qsTr("Continue my test install") : qsTr("Keep a test install")
                detail: panel.hasTestDisk
                        ? qsTr("The system you installed last time starts again.")
                        : qsTr("Run the installer inside the window and keep the result for next time. Uses up to 30 GB, only what is needed.")
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapS
                visible: panel.hasTestDisk
                Layout.fillWidth: true

                AppButton {
                    kind: "quiet"
                    text: qsTr("Delete test install")
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
