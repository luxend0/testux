import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes

CheckBox {
    id: control

    property string detail: ""

    spacing: Theme.gapM
    padding: 0

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: control.topPadding + 1
        radius: 6
        color: control.checked ? Theme.accent : Theme.surface
        border.width: control.checked ? 0 : 1.5
        border.color: control.hovered ? Theme.accent : Theme.borderStrong

        Shape {
            anchors.fill: parent
            visible: control.checked
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.accentText
                strokeWidth: 2.2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                startX: 5.5
                startY: 10.5
                PathLine { x: 8.7; y: 13.6 }
                PathLine { x: 14.8; y: 6.8 }
            }
        }

        FocusRing {
            baseRadius: 6
            visible: control.visualFocus
        }
    }
}
