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
            placeholderText: "Path to an ISO"
            text: "/home/luxend/isos/mint.iso"
        }

        RowLayout {
            Label {
                text: "RAM (MB)"
            }

            SpinBox {
                id: ram
                from: 1024
                to: 16384
                stepSize: 1024
                value: 4096
            }
        }

        Button {
            text: launcher.running ? "Stop" : "Boot"
            onClicked: launcher.running ? launcher.stop() : launcher.start(isoPath.text, ram.value)
        }
    }
}
