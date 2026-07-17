import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Shown after returning to Windows from a bare-metal boot, or whenever its boot files
// are still on the drive. Offers to remove them.
AppDialog {
    id: dialog

    readonly property bool working: BareMetal.state === BareMetal.Working
    property bool cleaning: false

    title: BareMetal.postBoot ? qsTr("Welcome back") : qsTr("Testux boot files found")
    closePolicy: working ? Popup.NoAutoClose : Popup.CloseOnEscape

    AppCheckBox {
        id: reclaim
        checked: true
        enabled: !dialog.working
        text: qsTr("Give unused Linux space back to Windows")
        detail: qsTr("Leave this on unless you installed Linux. Space that Linux uses is never touched.")
        Layout.fillWidth: true
    }

    ColumnLayout {
        visible: dialog.working
        spacing: Theme.gapS
        Layout.fillWidth: true

        BodyText {
            text: BareMetal.step
            muted: true
            Layout.fillWidth: true
        }

        AppProgressBar {
            value: BareMetal.progress
            Layout.fillWidth: true
        }
    }
}
