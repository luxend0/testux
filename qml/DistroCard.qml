import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

AbstractButton {
    id: card

    required property distro distro

    padding: Theme.gapL + 2
    implicitWidth: 260
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: ColumnLayout {
        spacing: Theme.gapM

        RowLayout {
            spacing: Theme.gapM

            DistroTile {
                name: card.distro.name
                tint: card.distro.color
            }

            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Label {
                    text: card.distro.name
                    font.pixelSize: Theme.fontLarge
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: [card.distro.edition, card.distro.version].filter(Boolean).join(" ")
                    color: Theme.textMuted
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        BodyText {
            text: card.distro.summary
            muted: true
            maximumLineCount: 2
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.preferredHeight: Math.ceil(2 * summaryMetrics.height * lineHeight) + 2

            FontMetrics {
                id: summaryMetrics
                font: card.font
            }
        }

        Label {
            text: Format.desktopAndBase(card.distro)
            font.pixelSize: Theme.fontSmall
            color: Theme.textFaint
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Theme.gapL

            Flag {
                text: qsTr("Secure Boot")
                on: card.distro.secureBoot
            }

            Flag {
                text: qsTr("Live session")
                on: card.distro.liveSession
            }
        }
    }
}
