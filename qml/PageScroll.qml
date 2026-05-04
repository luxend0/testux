import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Scrollable page body: a centered column with page margins and a maximum width.
ScrollView {
    id: page

    default property alias content: column.data
    property int maximumContentWidth: 1180
    readonly property real contentColumnWidth: column.width

    contentWidth: availableWidth
    contentHeight: column.implicitHeight + 2 * Theme.gapXxl
    clip: true

    ColumnLayout {
        id: column
        x: Math.round((page.availableWidth - width) / 2)
        y: Theme.gapXxl
        width: Math.min(page.availableWidth - 2 * Theme.gapXxl, page.maximumContentWidth)
        spacing: Theme.gapXl
    }
}
