import QtQuick
import QtQuick.Controls.Basic

ProgressBar {
    id: bar

    contentItem: Item {
        implicitHeight: 8
        clip: true

        Rectangle {
            visible: !bar.indeterminate
            width: bar.visualPosition * parent.width
            height: parent.height
            radius: 4
            color: Theme.accent
        }

        Rectangle {
            id: runner
            visible: bar.indeterminate
            width: parent.width * 0.3
            height: parent.height
            radius: 4
            color: Theme.accent

            NumberAnimation on x {
                running: bar.indeterminate && bar.visible
                from: -runner.width
                to: bar.width
                duration: 1200
                loops: Animation.Infinite
            }
        }
    }
}
