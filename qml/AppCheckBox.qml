import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes

// Checkbox with an optional second line of explanation.
CheckBox {
    id: control

    property string detail: ""

    spacing: Theme.gapM
    padding: 0
}
