import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

// Scrollable page body: a centered column with page margins and a maximum width.
ScrollView {
    id: page

    default property alias content: column.data
    property int maximumContentWidth: 1180
    readonly property real contentColumnWidth: column.width
}
