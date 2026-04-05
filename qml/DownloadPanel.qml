import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Download state of one ISO with the matching action.
ColumnLayout {
    id: panel

    required property distro distro
    required property IsoDownload download

    readonly property real total: download.total > 0 ? download.total : distro.isoSize

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
