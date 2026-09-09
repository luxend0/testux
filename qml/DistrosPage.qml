pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
    id: page

    signal distroSelected(string id)

    readonly property DistroFilter filter: DistroFilter {
        pcRamMb: HardwareCheck.report.valid ? HardwareCheck.report.ramMb : 0
        categoryTitles: Catalog.categories.reduce((titles, c) => {
            titles[c.id] = c.title
            return titles
        }, {})
    }
    readonly property int shownCount: Catalog.distros.filter(d => filter.matches(d)).length
    readonly property bool empty: Catalog.distros.length === 0

    // Choices for tabs and menus, all taken from the catalog so new entries need no code change.
    readonly property list<var> categoryOptions: [
        { value: "", label: qsTr("All") },
        ...Catalog.categories.map(c => ({ value: c.id, label: c.title }))
    ]
    readonly property list<var> desktopOptions: distinctOptions(Catalog.distros.map(d => d.desktop))
    readonly property list<var> baseOptions: distinctOptions(Catalog.distros.map(d => d.base))
    readonly property list<var> featureOptions: [
        { value: "secureBoot", label: qsTr("Works with Secure Boot") },
        { value: "liveSession", label: qsTr("Live session") },
        { value: "nvidiaReady", label: qsTr("NVIDIA driver included") },
        { value: "rolling", label: qsTr("Rolling updates") },
        { value: "fixed", label: qsTr("Fixed releases") },
        ...(HardwareCheck.report.valid ? [{ value: "fitsPc", label: qsTr("Fits my PC") }] : [])
    ]
    readonly property bool featuresAsChips: contentColumnWidth >= 1000

    function distinctOptions(values: list<string>): list<var> {
        return [...new Set(values.filter(value => value !== ""))]
            .sort((a, b) => a.localeCompare(b))
            .map(value => ({ value: value, label: Format.baseName(value) }))
    }

    function focusSearch() {
        search.forceActiveFocus()
        search.selectAll()
    }

    Component.onCompleted: search.forceActiveFocus()
    StackView.onActivated: search.forceActiveFocus()

    // Typing anywhere on the page goes to the search field.
    Keys.onPressed: event => {
        const plainKey = !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
        if (plainKey && event.text.length === 1 && event.text.trim() !== "") {
            search.forceActiveFocus()
            search.insert(search.cursorPosition, event.text)
            event.accepted = true
        }
    }

    Shortcut {
        sequences: [StandardKey.Find]
        enabled: page.visible
        onActivated: page.focusSearch()
    }

    PageHeader {
        title: qsTr("Pick a Linux to try")
        subtitle: qsTr("Every distro runs in a window first, so nothing on your PC changes until you decide.")
    }

    Notice {
        visible: Catalog.latestAppVersion !== "" && Format.isNewer(Catalog.latestAppVersion, Qt.application.version)
        text: qsTr("Testux %1 is available.").arg(Catalog.latestAppVersion)
        Layout.fillWidth: true

        AppButton {
            kind: "quiet"
            text: qsTr("Get the update")
            onClicked: Qt.openUrlExternally(Catalog.latestAppUrl)
        }
    }

    Notice {
        visible: Catalog.error !== "" && !page.empty
        text: qsTr("The online list could not be loaded, showing the list built into Testux.")
        Layout.fillWidth: true
    }

    ColumnLayout {
        visible: !page.empty
        spacing: Theme.gapM
        Layout.fillWidth: true

        SearchBox {
            id: search
            placeholderText: qsTr("Search by name, desktop or base")
            text: page.filter.query
            onTextChanged: page.filter.query = text
            Layout.fillWidth: true
        }

        // Tabs while they fit, otherwise the category moves into a menu in the filter row.
        SegmentedControl {
            id: categoryTabs
            visible: implicitWidth <= page.contentColumnWidth
            current: page.filter.category
            options: page.categoryOptions
            onPicked: value => page.filter.category = value
        }

        Flow {
            spacing: Theme.gapS
            Layout.fillWidth: true

            ChoiceMenu {
                visible: !categoryTabs.visible
                title: qsTr("Category")
                options: page.categoryOptions
                current: page.filter.category
                onPicked: value => page.filter.category = value
            }

            FilterMenu {
                title: qsTr("Desktop")
                options: page.desktopOptions
                selected: page.filter.desktops
                onOptionToggled: (value, on) => page.filter.desktops = page.filter.toggled(page.filter.desktops, value, on)
            }

            FilterMenu {
                title: qsTr("Based on")
                options: page.baseOptions
                selected: page.filter.bases
                onOptionToggled: (value, on) => page.filter.bases = page.filter.toggled(page.filter.bases, value, on)
            }

            // Wide enough: one chip per yes/no filter. Narrow: the same choices in one menu.
            Repeater {
                model: page.featuresAsChips ? page.featureOptions : []

                FilterChip {
                    required property var modelData

                    text: modelData.label
                    checked: page.filter.features.includes(modelData.value)
                    onToggled: page.filter.setFeature(modelData.value, checked)
                }
            }

            FilterMenu {
                visible: !page.featuresAsChips
                title: qsTr("More")
                options: page.featureOptions
                selected: page.filter.features
                onOptionToggled: (value, on) => page.filter.setFeature(value, on)
            }
        }

        RowLayout {
            spacing: Theme.gapS
            Layout.fillWidth: true

            Label {
                text: page.filter.active
                      ? qsTr("%1 of %2 distros").arg(page.shownCount).arg(Catalog.distros.length)
                      : qsTr("%1 distros").arg(Catalog.distros.length)
                color: Theme.textFaint
            }

            AppButton {
                kind: "quiet"
                visible: page.filter.active
                text: qsTr("Clear filters")
                onClicked: page.filter.clear()
            }
        }
    }

    RowLayout {
        visible: page.empty && Catalog.loading
        spacing: Theme.gapM

        BusyIndicator {
            running: visible
            implicitWidth: 28
            implicitHeight: 28
        }

        Label {
            text: qsTr("Loading the distro list")
            color: Theme.textMuted
        }
    }

    Notice {
        kind: "error"
        visible: page.empty && !Catalog.loading
        title: qsTr("No distros to show")
        text: Catalog.error
        Layout.fillWidth: true

        AppButton {
            text: qsTr("Try again")
            onClicked: Catalog.refresh()
        }
    }

    Panel {
        visible: !page.empty && page.shownCount === 0
        Layout.fillWidth: true

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.gapM

            Heading {
                text: qsTr("No distro matches")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            BodyText {
                text: qsTr("Try fewer filters or another search word.")
                muted: true
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            AppButton {
                kind: "primary"
                text: qsTr("Clear filters")
                onClicked: page.filter.clear()
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    GridLayout {
        id: grid

        // Fixed card width, so a short result list keeps the same card size.
        readonly property real cardWidth: (page.contentColumnWidth - (columns - 1) * columnSpacing) / columns

        columns: Math.max(1, Math.floor((page.contentColumnWidth + columnSpacing) / (250 + columnSpacing)))
        columnSpacing: Theme.gapL
        rowSpacing: Theme.gapL
        Layout.fillWidth: true

        // Every card exists once; filtering only hides cards, so typing never rebuilds the grid.
        Repeater {
            model: Catalog.distros

            DistroCard {
                required property distro modelData

                visible: page.filter.matches(modelData)
                distro: modelData
                onClicked: page.distroSelected(modelData.id)
                Layout.preferredWidth: grid.cardWidth
                Layout.fillHeight: true
            }
        }
    }
}
