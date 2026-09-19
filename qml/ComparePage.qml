pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: page

    signal distroSelected(string id)

    // measurement() does not notify, so the table re-reads it on this counter.
    property int measurementRevision: 0
    readonly property var measured: {
        void measurementRevision
        const result = {}
        for (const d of Catalog.distros) {
            const m = VmManager.measurement(d.id)
            if (m.ramUsedMb)
                result[d.id] = m.ramUsedMb
        }
        return result
    }
    readonly property bool anyMeasured: Object.keys(measured).length > 0

    property string sortKey: "name"
    readonly property list<var> sortOptions: [
        { value: "name", label: qsTr("Name") },
        { value: "size", label: qsTr("Download size") },
        { value: "ram", label: qsTr("Minimum meomry") },
        { value: "measured", label: qsTr("Your memory use") }
    ]
    readonly property list<distro> sorted: sortedDistros(Catalog.distros, sortKey, measured)

    function sortedDistros(distros: list<distro>, key: string, ram: var): list<distro> {
        const byName = (a, b) => Format.fullName(a).localeCompare(Format.fullName(b))
        const compare = {
            name: byName,
            size: (a, b) => a.isoSize - b.isoSize || byName(a, b),
            ram: (a, b) => a.minRamMb - b.minRamMb || byName(a, b),
            // Measured distros first, lightest first. Infinity - Infinity is NaN, so name decides.
            measured: (a, b) => (ram[a.id] ?? Infinity) - (ram[b.id] ?? Infinity) || byName(a, b)
        }[key]
        return [...distros].sort(compare)
    }

    function cellsFor(d: distro): list<string> {
        const ram = measured[d.id]
        return [
            Format.fullName(d),
            d.desktop,
            Format.baseName(d.base),
            d.releaseModel === "rolling" ? qsTr("Rolling") : qsTr("Fixed"),
            Format.bytes(d.isoSize),
            Format.megabytes(d.minRamMb),
            Format.yesNo(d.secureBoot),
            Format.yesNo(d.liveSession),
            d.nvidiaReady ? qsTr("Included") : qsTr("Later"),
            ram ? Format.megabytes(ram) : qsTr("Not tried yet")
        ]
    }

    readonly property list<var> columns: [
        { title: qsTr("Distro"), width: 200 },
        { title: qsTr("Desktop"), width: 120 },
        { title: qsTr("Based on"), width: 110 },
        { title: qsTr("Updates"), width: 90 },
        { title: qsTr("Download"), width: 80 },
        { title: qsTr("Min. memory"), width: 90 },
        { title: qsTr("Secure Boot"), width: 90 },
        { title: qsTr("Live"), width: 60 },
        { title: qsTr("NVIDIA"), width: 70 },
        { title: qsTr("Your memory use"), width: 120 }
    ]
    readonly property real tableWidth: columns.reduce((sum, column) => sum + column.width, 0) + 2 * Theme.gapL

    Connections {
        target: VmManager

        function onMeasurementsChanged() {
            ++page.measurementRevision
        }
    }

    ColumnLayout {
        x: Math.round((page.width - width) / 2)
        y: Theme.gapXxl
        width: Math.min(page.width - 2 * Theme.gapXxl, 1180)
        height: page.height - 2 * Theme.gapXxl
        spacing: Theme.gapXl

        PageHeader {
            title: qsTr("Compare")
            subtitle: qsTr("The facts side by side. Memory use is measured on your PC while a distro runs in a window.")
        }

        Notice {
            visible: !page.anyMeasured
            text: qsTr("\"Your memory use\" fills in as you try distros. Start one in a window and look at it for a minute.")
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Theme.gapM
            Layout.fillWidth: true

            ChoiceMenu {
                title: qsTr("Sort by")
                options: page.sortOptions
                current: page.sortKey
                highlighted: false
                onPicked: value => page.sortKey = value
            }

            Label {
                text: qsTr("%1 distros").arg(Catalog.distros.length)
                color: Theme.textFaint
            }
        }

        Panel {
            id: tablePanel

            padding: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Horizontal scrolling for narrow windows; the list inside scrolls vertically and
            // keeps the header row on top.
            Flickable {
                anchors.fill: parent
                contentWidth: rows.width
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                ScrollBar.horizontal: ScrollBar {}

                ListView {
                    id: rows

                    width: Math.max(tablePanel.availableWidth, page.tableWidth)
                    height: parent.height
                    clip: true
                    model: page.sorted
                    boundsBehavior: Flickable.StopAtBounds
                    headerPositioning: ListView.OverlayHeader

                    ScrollBar.vertical: ScrollBar {
                        parent: tablePanel
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            topMargin: Theme.gapS
                            bottomMargin: Theme.gapS
                        }
                    }

                    header: CompareRow {
                        z: 2
                        width: ListView.view.width
                        header: true
                        columns: page.columns
                        cells: page.columns.map(column => column.title)
                    }

                    delegate: CompareRow {
                        required property distro modelData

                        width: ListView.view.width
                        columns: page.columns
                        distro: modelData
                        cells: page.cellsFor(modelData)
                        lastCellFaded: !page.measured[modelData.id]
                        onClicked: page.distroSelected(modelData.id)
                    }
                }
            }
        }
    }
}
