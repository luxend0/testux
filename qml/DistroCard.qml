import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

AbstractButton {
    id: card

    required property distro distro
    // Why the quiz picked it; replaces the feature line when set.
    property string reason: ""

    padding: Theme.gapL + 2
    implicitWidth: 260
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        radius: Theme.radiusLarge
        color: card.down ? Theme.surfaceMuted : Theme.surface
        border.color: card.hovered ? Theme.borderStrong : Theme.border

        FocusRing {
            baseRadius: Theme.radiusLarge
            visible: card.visualFocus
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.gapM

        RowLayout {
            spacing: Theme.gapM

            DistroTile {
                name: card.distro.name
                tint: card.distro.color
                logo: card.distro.logo
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
            // Two lines high even for short summaries, so cards in a row line up.
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

        Flag {
            visible: card.reason === ""
            text: card.distro.liveSession ? qsTr("Try without installing") : qsTr("Installer only")
            on: card.distro.liveSession
        }

        Label {
            visible: card.reason !== ""
            text: card.reason
            color: Theme.accent
            font.pixelSize: Theme.fontSmall
            font.weight: Font.DemiBold
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }
}
