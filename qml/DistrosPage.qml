pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
    id: page

    signal distroSelected(string id)

    property string category: ""
    readonly property list<var> categoryOptions: [
        { value: "", label: qsTr("All") },
        { value: "beginner", label: qsTr("Beginner") },
        { value: "kde", label: qsTr("KDE Plasma") },
        { value: "gaming", label: qsTr("Gaming") },
        { value: "other", label: qsTr("More") }
    ]
    readonly property list<distro> shown: Catalog.distros.filter(d => category === "" || d.category === category)

    PageHeader {
        title: qsTr("Pick a Linux to try")
        subtitle: qsTr("Every distro runs in a window first, so nothing on your PC changes until you decide.")
    }

    Notice {
        visible: Catalog.error !== "" && Catalog.distros.length > 0
        text: qsTr("The online list could not be loaded, showing the list built into Testux.")
        Layout.fillWidth: true
    }

    SegmentedControl {
        current: page.category
        options: page.categoryOptions
        onPicked: value => page.category = value
    }

    GridLayout {
        id: grid

        readonly property real cardWidth: (page.contentColumnWidth - (columns - 1) * columnSpacing) / columns

        columns: Math.max(1, Math.floor((page.contentColumnWidth + columnSpacing) / (250 + columnSpacing)))
        columnSpacing: Theme.gapL
        rowSpacing: Theme.gapL
        Layout.fillWidth: true

        Repeater {
            model: page.shown

            DistroCard {
                required property distro modelData

                distro: modelData
                onClicked: page.distroSelected(modelData.id)
                Layout.preferredWidth: grid.cardWidth
                Layout.fillHeight: true
            }
        }
    }
}
