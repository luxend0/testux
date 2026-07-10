import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Download state of one ISO with the matching action.
ColumnLayout {
    id: panel

    required property distro distro
    required property IsoDownload download

    readonly property real total: download.total > 0 ? download.total : distro.isoSize

    spacing: Theme.gapS

    RowLayout {
        spacing: Theme.gapM
        visible: panel.download.state === IsoDownload.Missing
        Layout.fillWidth: true

        BodyText {
            text: panel.download.received > 0
                  ? qsTr("Download paused at %1 of %2.").arg(Format.bytes(panel.download.received)).arg(Format.bytes(panel.total))
                  : qsTr("First Testux downloads the official ISO (%1) and checks it.").arg(Format.bytes(panel.total))
            muted: true
            Layout.fillWidth: true
        }

        AppButton {
            kind: "primary"
            text: panel.download.received > 0 ? qsTr("Resume") : qsTr("Download")
            onClicked: panel.download.start()
        }
    }

    ColumnLayout {
        spacing: Theme.gapS
        visible: panel.download.state === IsoDownload.Downloading || panel.download.state === IsoDownload.Verifying
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: panel.download.state === IsoDownload.Verifying
                      ? qsTr("Checking the download")
                      : qsTr("Downloading %1 of %2").arg(Format.bytes(panel.download.received)).arg(Format.bytes(panel.total))
                color: Theme.textMuted
                Layout.fillWidth: true
            }

            AppButton {
                kind: "quiet"
                text: qsTr("Pause")
                visible: panel.download.state === IsoDownload.Downloading
                onClicked: panel.download.cancel()
            }
        }

        AppProgressBar {
            value: panel.total > 0 ? panel.download.received / panel.total : 0
            indeterminate: panel.download.state === IsoDownload.Verifying
            Layout.fillWidth: true
        }
    }

    RowLayout {
        spacing: Theme.gapS
        visible: panel.download.state === IsoDownload.Ready
        Layout.fillWidth: true

        StatusDot {}

        Label {
            text: qsTr("ISO downloaded and verified (%1)").arg(Format.bytes(panel.total))
            color: Theme.textMuted
            Layout.fillWidth: true
        }

        AppButton {
            kind: "quiet"
            text: qsTr("Delete ISO")
            onClicked: panel.download.remove()
        }
    }

    Notice {
        kind: "error"
        visible: panel.download.state === IsoDownload.Failed
        title: qsTr("The download did not work")
        text: panel.download.error
        Layout.fillWidth: true

        AppButton {
            text: qsTr("Try again")
            onClicked: panel.download.start()
        }
    }
}
