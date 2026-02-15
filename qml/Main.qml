import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Testux

ApplicationWindow {
    width: 800
    height: 500
    visible: true
    title: "Testux"

    Launcher {
        id: launcher
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        TextField {
            id: isoPath
            Layout.preferredWidth: 420
            text: "/home/luxend/isos/mint.iso"
        }

        Button {
            text: "Boot"
            onClicked: launcher.start(isoPath.text)
        }
    }
}
