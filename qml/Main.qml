pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    id: window

    property string section: "distros"

    readonly property var sections: [
        { key: "distros", title: qsTr("Distros") },
        { key: "compare", title: qsTr("Compare") },
        { key: "pc", title: qsTr("This PC") },
        { key: "settings", title: qsTr("Settings") }
    ]

    function showSection(key: string) {
        section = key
        const pages = { distros: distrosPage, compare: comparePage, pc: thisPcPage, settings: settingsPage }
        stack.replace(null, pages[key])
    }

    function openDistro(id: string) {
        const distro = Catalog.distro(id)
        if (distro.id !== "")
            stack.push(distroPage, { distro: distro })
    }

    function openBootWizard(id: string) {
        stack.push(bootWizard, { distro: Catalog.distro(id) })
    }

    width: 1180
    height: 760
    minimumWidth: 960
    minimumHeight: 640
    visible: true
    title: "Testux"
    color: Theme.background
    font.pixelSize: Theme.fontBase

    palette {
        window: Theme.background
        windowText: Theme.text
        base: Theme.surface
        text: Theme.text
        button: Theme.surface
        buttonText: Theme.text
        highlight: Theme.accent
        highlightedText: Theme.accentText
        placeholderText: Theme.textFaint
        dark: Theme.textMuted
        mid: Theme.borderStrong
        midlight: Theme.border
        light: Theme.surface
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            sections: window.sections
            current: window.section
            onPicked: key => window.showSection(key)
            Layout.fillHeight: true
        }

        StackView {
            id: stack

            initialItem: distrosPage
            Layout.fillWidth: true
            Layout.fillHeight: true

            pushEnter: FadeIn {}
            pushExit: FadeOut {}
            popEnter: FadeIn {}
            popExit: FadeOut {}
            replaceEnter: FadeIn {}
            replaceExit: FadeOut {}
        }
    }

    Component {
        id: distrosPage

        DistrosPage {
            onDistroSelected: id => window.openDistro(id)
        }
    }

    Component {
        id: distroPage

        DistroPage {
            id: detail

            onBackRequested: stack.pop()
            onBootRequested: window.openBootWizard(detail.distro.id)
        }
    }

    Component {
        id: bootWizard

        BootWizard {
            onBackRequested: stack.pop()
        }
    }

    Component {
        id: comparePage

        ComparePage {
            onDistroSelected: id => window.openDistro(id)
        }
    }

    Component {
        id: thisPcPage

        ThisPcPage {}
    }

    Component {
        id: settingsPage

        SettingsPage {}
    }

    WelcomeBackDialog {
        id: welcomeBack
    }

    Component.onCompleted: {
        if (BareMetal.postBoot || BareMetal.pending)
            welcomeBack.open()
    }
}
