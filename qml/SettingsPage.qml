import QtQuick
import QtQuick.Layouts

PageScroll {
    id: page

    readonly property string repositoryUrl: "https://github.com/luxend0/testux"

    PageHeader {
        title: qsTr("Settings")
    }

    Panel {
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gapM

            Heading {
                text: qsTr("Downloads")
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapM
                Layout.fillWidth: true

                BodyText {
                    text: IsoLibrary.usedBytes > 0
                          ? qsTr("Downloaded ISOs take up %1.").arg(Format.bytes(IsoLibrary.usedBytes))
                          : qsTr("No ISOs downloaded.")
                    muted: true
                    Layout.fillWidth: true
                }

                AppButton {
                    kind: "danger"
                    text: qsTr("Delete all ISOs")
                    enabled: IsoLibrary.usedBytes > 0
                    onClicked: confirmRemoval.open()
                }
            }
        }
    }
}
