import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// The first-start tour: dims the window, cuts a hole around the item a step talks about and
// shows a bubble next to it. Steps are [{ target: Item or null, title, text }]; a step without
// target shows the bubble in the middle.
Item {
    id: tour

    property var steps: []
    // Called with a step's target before measuring it, e.g. to scroll it into view.
    property var reveal: null
    property int index: 0
    readonly property var step: steps[index] ?? null
    readonly property bool last: index === steps.length - 1
    property rect hole: Qt.rect(0, 0, 0, 0)
    readonly property bool hasHole: hole.width > 0

    signal finished()

    function start(stepList) {
        steps = stepList
        index = 0
        visible = true
        refresh()
    }

    function stop() {
        visible = false
        finished()
    }

    function go(newIndex: int) {
        index = newIndex
        refresh()
    }

    // Targets may sit in a scrolled page: scroll them into view first, measure once laid out.
    function refresh() {
        const target = step ? step.target : null
        if (target && target.visible && reveal)
            reveal(target)
        Qt.callLater(() => {
            const t = tour.step ? tour.step.target : null
            if (!t || !t.visible) {
                tour.hole = Qt.rect(0, 0, 0, 0)
                return
            }
            const r = t.mapToItem(tour, 0, 0, t.width, t.height)
            const pad = 8
            tour.hole = Qt.rect(r.x - pad, r.y - pad, r.width + 2 * pad, Math.min(r.height + 2 * pad, tour.height * 0.55))
        })
    }

    anchors.fill: parent
    visible: false
    z: 1000

    onWidthChanged: if (visible) refresh()
    onHeightChanged: if (visible) refresh()

    // Swallows clicks and wheel events so the page below stays put during the tour.
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: wheel => wheel.accepted = true
    }

    // Four dim panes around the hole, one full pane without a hole.
    readonly property color dim: "#99101826"
    Rectangle { color: tour.dim; x: 0; y: 0; width: tour.width; height: tour.hasHole ? tour.hole.y : tour.height }
    Rectangle { visible: tour.hasHole; color: tour.dim; x: 0; y: tour.hole.y + tour.hole.height; width: tour.width; height: tour.height - y }
    Rectangle { visible: tour.hasHole; color: tour.dim; x: 0; y: tour.hole.y; width: tour.hole.x; height: tour.hole.height }
    Rectangle { visible: tour.hasHole; color: tour.dim; x: tour.hole.x + tour.hole.width; y: tour.hole.y; width: tour.width - x; height: tour.hole.height }

    Rectangle {
        visible: tour.hasHole
        x: tour.hole.x
        y: tour.hole.y
        width: tour.hole.width
        height: tour.hole.height
        radius: Theme.radiusLarge
        color: "transparent"
        border.color: Theme.accent
        border.width: 3
    }

    Rectangle {
        id: bubble

        readonly property real gap: Theme.gapL
        readonly property bool below: tour.hole.y + tour.hole.height + gap + height <= tour.height
        readonly property bool rightOf: tour.hole.x + tour.hole.width + gap + width <= tour.width

        width: Math.min(400, tour.width - 2 * Theme.gapXl)
        height: column.implicitHeight + 2 * Theme.gapXl
        radius: Theme.radiusLarge
        color: Theme.surface
        border.color: Theme.border

        // Below the hole if it fits, else beside it, else above; centered without a hole.
        x: {
            if (!tour.hasHole)
                return (tour.width - width) / 2
            if (!below && rightOf && tour.hole.height > tour.height * 0.4)
                return tour.hole.x + tour.hole.width + gap
            return Math.max(Theme.gapL, Math.min(tour.hole.x, tour.width - width - Theme.gapL))
        }
        y: {
            if (!tour.hasHole)
                return (tour.height - height) / 2
            if (below)
                return tour.hole.y + tour.hole.height + gap
            if (rightOf && tour.hole.height > tour.height * 0.4)
                return Math.max(Theme.gapL, tour.hole.y)
            return Math.max(Theme.gapL, tour.hole.y - height - gap)
        }

        ColumnLayout {
            id: column
            spacing: Theme.gapM
            anchors {
                fill: parent
                margins: Theme.gapXl
            }

            Label {
                text: qsTr("Step %1 of %2").arg(tour.index + 1).arg(tour.steps.length)
                color: Theme.textFaint
                font.pixelSize: Theme.fontSmall
            }

            Label {
                text: tour.step ? tour.step.title : ""
                font.pixelSize: Theme.fontTitle
                font.weight: Font.Bold
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            BodyText {
                text: tour.step ? tour.step.text : ""
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapS
                Layout.topMargin: Theme.gapS
                Layout.fillWidth: true

                AppButton {
                    kind: "quiet"
                    visible: !tour.last
                    text: qsTr("Skip tour")
                    onClicked: tour.stop()
                }

                Item {
                    Layout.fillWidth: true
                }

                AppButton {
                    visible: tour.index > 0
                    text: qsTr("Back")
                    onClicked: tour.go(tour.index - 1)
                }

                AppButton {
                    id: next
                    kind: "primary"
                    text: tour.last ? qsTr("Let's go") : qsTr("Next")
                    focus: true
                    onClicked: tour.last ? tour.stop() : tour.go(tour.index + 1)
                }
            }
        }
    }

    // Pages grab focus for their search field when they appear; keep it in the bubble.
    Connections {
        target: tour.Window.window
        enabled: tour.visible

        function onActiveFocusItemChanged() {
            let item = tour.Window.activeFocusItem
            while (item && item !== tour)
                item = item.parent
            if (!item)
                Qt.callLater(() => next.forceActiveFocus())
        }
    }

    Keys.onEscapePressed: stop()
    Keys.onRightPressed: if (!last) go(index + 1)
    Keys.onLeftPressed: if (index > 0) go(index - 1)
    onVisibleChanged: if (visible) next.forceActiveFocus()
}
