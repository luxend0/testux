pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
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

    PageHeader {
        title: qsTr("Compare")
        subtitle: qsTr("The facts side by side. Memory use is measured on your PC while a distro runs in a window.")
    }

    Notice {
        visible: !page.anyMeasured
        text: qsTr("\"Your memory use\" fills in as you try distros. Start one in a window and look at it for a minute.")
        Layout.fillWidth: true
    }

    Panel {
        padding: 0
        Layout.fillWidth: true

        Column {
            width: parent.width

            CompareRow {
                width: parent.width
                header: true
                columns: page.columns
                cells: page.columns.map(column => column.title)
            }

            Repeater {
                model: Catalog.distros

                CompareRow {
                    required property distro modelData

                    width: parent.width
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
