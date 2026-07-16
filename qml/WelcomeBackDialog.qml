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
}
