import QtQuick
import QtQuick.Controls.Basic

AbstractButton {
    id: item

    property bool current: false

    padding: Theme.gapM
    leftPadding: Theme.gapL
    implicitHeight: 40
}
