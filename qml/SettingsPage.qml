import QtQuick
import QtQuick.Layouts

PageScroll {
    id: page

    readonly property string repositoryUrl: "https://github.com/luxend0/testux"

    PageHeader {
        title: qsTr("Settings")
    }
}
