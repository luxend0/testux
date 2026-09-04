import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Shapes

// Chip with a chevron that opens a popup list. Items placed inside go into the popup.
AbstractButton {
    id: button

    default property alias menuContent: menuGrid.data
    property bool highlighted: false
    property int optionCount: 0
    readonly property int menuColumns: optionCount > 10 ? 2 : 1
    readonly property bool menuOpen: popup.opened

    function closeMenu() {
        popup.close()
    }

    // Scrolls the option list so `item` (an option inside the popup) is fully visible.
    function revealItem(item: Item) {
        const flick = scroller.contentItem as Flickable
        const top = item.mapToItem(menuGrid, 0, 0).y
        if (top < flick.contentY)
            flick.contentY = top
        else if (top + item.height > flick.contentY + flick.height)
            flick.contentY = top + item.height - flick.height
    }

    horizontalPadding: Theme.gapM + 2
    implicitHeight: 38
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    onClicked: {
        if (popup.opened) {
            popup.close()
            return
        }
        popup.focusFirstOption = visualFocus
        popup.open()
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Row {
        spacing: Theme.gapS

        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: button.text
            font.weight: button.highlighted ? Font.DemiBold : Font.Normal
            color: button.highlighted ? Theme.accent : Theme.textMuted
        }

        Shape {
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 6
            rotation: popup.opened ? 180 : 0
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: button.highlighted ? Theme.accent : Theme.textMuted
                strokeWidth: 1.6
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                startX: 1
                startY: 1
                PathLine { x: 5; y: 5 }
                PathLine { x: 9; y: 1 }
            }
        }
    }

    background: Rectangle {
        radius: Theme.radius
        color: button.highlighted ? Theme.accentSoft : (button.hovered || popup.opened ? Theme.surfaceMuted : Theme.surface)
        border.color: button.highlighted ? Theme.accent : Theme.border

        FocusRing {
            baseRadius: Theme.radius
            visible: button.visualFocus
        }
    }

    Popup {
        id: popup

        // Room between the popup's top and the window bottom, measured when it opens.
        property real maximumHeight: 400
        property bool focusFirstOption: false

        y: button.height + Theme.gapXs + 2
        margins: Theme.gapL
        padding: Theme.gapM
        height: Math.min(implicitHeight, maximumHeight)
        focus: true

        onAboutToShow: {
            const top = button.mapToItem(null, 0, y).y
            maximumHeight = Math.max(160, Overlay.overlay.height - top - Theme.gapL)
        }
        onOpened: {
            if (focusFirstOption)
                menuGrid.nextItemInFocusChain(true)?.forceActiveFocus(Qt.TabFocusReason)
        }

        background: Rectangle {
            radius: Theme.radius
            color: Theme.surface
            border.color: Theme.borderStrong
        }

        contentItem: ScrollView {
            id: scroller

            readonly property bool scrolls: contentHeight > availableHeight

            contentWidth: menuGrid.implicitWidth
            contentHeight: menuGrid.implicitHeight
            // Room for the options' focus rings, which the clipping would cut off otherwise.
            padding: Theme.gapXs
            rightPadding: scrolls ? ScrollBar.vertical.width + Theme.gapS : Theme.gapXs
            clip: true
            ScrollBar.vertical.policy: scrolls ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded

            GridLayout {
                id: menuGrid
                flow: GridLayout.TopToBottom
                rows: Math.max(1, Math.ceil(button.optionCount / button.menuColumns))
                columnSpacing: Theme.gapXl
                rowSpacing: Theme.gapM
            }
        }
    }
}
