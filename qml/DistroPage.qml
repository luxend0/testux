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
}
