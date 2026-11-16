import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Scrollable page body: a centered column with page margins and a maximum width.
ScrollView {
    id: page

    default property alias content: column.data
    property int maximumContentWidth: 1180
    readonly property real contentColumnWidth: column.width

    // Scrolls so `item` (inside this page) starts near the top, as far as the page allows.
    function reveal(item: Item) {
        let inside = false
        for (let p = item; p && !inside; p = p.parent)
            inside = p === column
        if (!inside)
            return
        const flick = contentItem as Flickable
        const y = item.mapToItem(column, 0, 0).y + column.y - Theme.gapXl
        flick.contentY = Math.max(0, Math.min(y, flick.contentHeight - flick.height))
    }

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
