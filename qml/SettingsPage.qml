import QtQuick
import QtQuick.Layouts

PageScroll {
    id: page

    readonly property string repositoryUrl: "https://github.com/luxend0/testux"

    maximumContentWidth: 820

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

    Panel {
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gapM

            Heading {
                text: qsTr("Distro list")
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapM
                Layout.fillWidth: true

                BodyText {
                    text: qsTr("Distros in the list: %1. It updates by itself every time Testux starts.").arg(Catalog.distros.length)
                    muted: true
                    Layout.fillWidth: true
                }

                AppButton {
                    text: Catalog.loading ? qsTr("Updating") : qsTr("Update now")
                    enabled: !Catalog.loading
                    onClicked: Catalog.refresh()
                }
            }
        }
    }

    Panel {
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gapM

            Heading {
                text: qsTr("About Testux")
                Layout.fillWidth: true
            }

            BodyText {
                text: qsTr("Version %1. Testux is free software under the GNU General Public License version 3.").arg(Qt.application.version)
                muted: true
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Theme.gapS
                Layout.leftMargin: -Theme.gapM

                AppButton {
                    kind: "quiet"
                    text: qsTr("Source code")
                    onClicked: Qt.openUrlExternally(page.repositoryUrl)
                }

                AppButton {
                    kind: "quiet"
                    text: qsTr("Report a problem")
                    onClicked: Qt.openUrlExternally(page.repositoryUrl + "/issues")
                }
            }
        }
    }

    AppDialog {
        id: confirmRemoval

        title: qsTr("Delete all ISOs?")

        BodyText {
            text: qsTr("This frees %1. Test disks stay. You can download any ISO again later.").arg(Format.bytes(IsoLibrary.usedBytes))
            muted: true
            Layout.fillWidth: true
        }

        actions: [
            AppButton {
                text: qsTr("Cancel")
                onClicked: confirmRemoval.reject()
            },
            AppButton {
                kind: "danger"
                text: qsTr("Delete")
                onClicked: {
                    IsoLibrary.removeAll()
                    confirmRemoval.accept()
                }
            }
        ]
    }
}
