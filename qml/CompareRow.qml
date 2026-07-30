pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// One line of the comparison table. The header row has no distro and is not clickable.
AbstractButton {
    id: row

    property bool header: false
    property list<var> columns
    property list<string> cells
    property distro distro
    property bool lastCellFaded: false

    enabled: !header
    padding: Theme.gapL
    topPadding: header ? Theme.gapM : Theme.gapS + 2
    bottomPadding: topPadding

    HoverHandler {
        enabled: !row.header
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        color: row.header ? Theme.surfaceMuted : (row.hovered ? "#f9fafc" : "transparent")
        radius: row.header ? Theme.radiusLarge : 0

        Rectangle {
            visible: row.header
            color: parent.color
            height: parent.radius
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }

        Rectangle {
            height: 1
            color: Theme.border
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }

        FocusRing {
            visible: row.visualFocus
        }
    }

    contentItem: RowLayout {
        spacing: 0

        Repeater {
            model: row.columns

            RowLayout {
                id: cell

                required property var modelData
                required property int index
                readonly property string value: row.cells[index] ?? ""

                spacing: Theme.gapS
                Layout.preferredWidth: modelData.width

                DistroTile {
                    visible: !row.header && cell.index === 0
                    name: row.distro.name
                    tint: row.distro.color
                    size: 24
                }

                Label {
                    text: cell.value
                    elide: Text.ElideRight
                    font.pixelSize: row.header ? Theme.fontSmall : Theme.fontBase
                    font.weight: row.header || cell.index === 0 ? Font.DemiBold : Font.Normal
                    color: {
                        if (row.header)
                            return Theme.textMuted
                        const faded = row.lastCellFaded && cell.index === row.columns.length - 1
                        return faded ? Theme.textFaint : Theme.text
                    }
                    Layout.fillWidth: true
                    Layout.rightMargin: Theme.gapS
                }
            }
        }
    }
}
