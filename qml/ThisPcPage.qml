import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

PageScroll {
    id: page

    readonly property hardwareReport report: HardwareCheck.report

    maximumContentWidth: 900
}
