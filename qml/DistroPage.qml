import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
    id: page

    required property distro distro

    signal backRequested()
    signal bootRequested()

    readonly property bool wide: contentColumnWidth > 1000
    readonly property string baseName: Format.baseName(distro.base)

    AppButton {
        kind: "quiet"
        text: qsTr("Back to all distros")
        onClicked: page.backRequested()
        Layout.leftMargin: -Theme.gapM
        Layout.bottomMargin: -Theme.gapM
    }

    RowLayout {
        spacing: Theme.gapL
        Layout.fillWidth: true

        DistroTile {
            name: page.distro.name
            tint: page.distro.color
            logo: page.distro.logo
            size: 72
        }

        ColumnLayout {
            spacing: Theme.gapXs
            Layout.fillWidth: true

            Label {
                text: Format.fullName(page.distro)
                font.pixelSize: Theme.fontHeadline
                font.weight: Font.Bold
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            BodyText {
                text: page.distro.summary
                muted: true
                font.pixelSize: Theme.fontLarge - 1
                Layout.fillWidth: true
            }
        }

        AppButton {
            kind: "quiet"
            visible: page.distro.website !== ""
            text: qsTr("Website")
            onClicked: Qt.openUrlExternally(page.distro.website)
            Layout.alignment: Qt.AlignTop
        }
    }

    GridLayout {
        columns: page.wide ? 2 : 1
        columnSpacing: Theme.gapXl
        rowSpacing: Theme.gapXl
        Layout.fillWidth: true

        ColumnLayout {
            spacing: Theme.gapXl
            Layout.fillWidth: true
            Layout.preferredWidth: 3
            Layout.alignment: Qt.AlignTop

            Panel {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.gapL

                    Heading {
                        text: qsTr("About %1").arg(page.distro.name)
                        Layout.fillWidth: true
                    }

                    BodyText {
                        text: page.distro.description
                        Layout.fillWidth: true
                    }

                    Notice {
                        kind: "warning"
                        visible: page.distro.notes !== ""
                        text: page.distro.notes
                        Layout.fillWidth: true
                    }
                }
            }

            TryPanel {
                distro: page.distro
                Layout.fillWidth: true
            }

            BootPanel {
                distro: page.distro
                onSetupRequested: page.bootRequested()
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            spacing: Theme.gapXl
            Layout.fillWidth: true
            Layout.preferredWidth: 2
            Layout.alignment: Qt.AlignTop

            Panel {
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.gapM

                    Heading {
                        text: qsTr("At a glance")
                        Layout.fillWidth: true
                    }

                    FactList {
                        facts: [
                            { label: qsTr("Version"), value: page.distro.version },
                            { label: qsTr("Desktop"), value: page.distro.desktop },
                            { label: qsTr("Based on"), value: page.baseName },
                            { label: qsTr("Updates"), value: Format.releaseModelName(page.distro.releaseModel) },
                            { label: qsTr("Download"), value: Format.bytes(page.distro.isoSize) },
                            { label: qsTr("Memory"), value: qsTr("%1 or more").arg(Format.megabytes(page.distro.minRamMb)) },
                            { label: qsTr("Secure Boot"), value: page.distro.secureBoot ? qsTr("Works with Secure Boot on") : qsTr("Secure Boot must be off") },
                            { label: qsTr("Live session"), value: page.distro.liveSession ? qsTr("Yes, try before installing") : qsTr("No, installer only") },
                            { label: qsTr("NVIDIA driver"), value: page.distro.nvidiaReady ? qsTr("Included or offered") : qsTr("Install it afterwards") }
                        ]
                        Layout.fillWidth: true
                    }
                }
            }

            ChecklistPanel {
                distro: page.distro
                Layout.fillWidth: true
            }
        }
    }
}
