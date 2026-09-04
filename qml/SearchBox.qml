import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes

TextField {
    id: field

    leftPadding: 44
    rightPadding: clearButton.visible ? 44 : Theme.gapL
    topPadding: 11
    bottomPadding: 11
    color: Theme.text
    placeholderTextColor: Theme.textFaint
    selectionColor: Theme.accentSoft
    selectedTextColor: Theme.text
    font.pixelSize: Theme.fontLarge - 1

    Keys.onEscapePressed: event => {
        event.accepted = text !== ""
        clear()
    }

    background: Rectangle {
        implicitWidth: 320
        implicitHeight: 44
        radius: Theme.radius
        color: Theme.surface
        border.width: field.activeFocus ? 2 : 1
        border.color: field.activeFocus ? Theme.accent : (field.hovered ? Theme.borderStrong : Theme.border)

        Shape {
            x: Theme.gapL
            anchors.verticalCenter: parent.verticalCenter
            width: 18
            height: 18
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: field.activeFocus ? Theme.accent : Theme.textFaint
                strokeWidth: 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: 7.5
                    centerY: 7.5
                    radiusX: 6
                    radiusY: 6
                    startAngle: 0
                    sweepAngle: 360
                }
            }

            ShapePath {
                strokeColor: field.activeFocus ? Theme.accent : Theme.textFaint
                strokeWidth: 2
                capStyle: ShapePath.RoundCap
                startX: 12
                startY: 12
                PathLine { x: 16.5; y: 16.5 }
            }
        }
    }

    AbstractButton {
        id: clearButton

        visible: field.text !== ""
        focusPolicy: Qt.NoFocus
        width: 28
        height: 28
        x: field.width - width - Theme.gapS - 2
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            field.clear()
            field.forceActiveFocus()
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        background: Rectangle {
            radius: width / 2
            color: clearButton.hovered ? Theme.border : Theme.surfaceMuted
        }

        contentItem: Shape {
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Theme.textMuted
                strokeWidth: 1.8
                capStyle: ShapePath.RoundCap
                startX: 10
                startY: 10
                PathLine { x: 18; y: 18 }
                PathMove { x: 18; y: 10 }
                PathLine { x: 10; y: 18 }
            }
        }
    }
}
