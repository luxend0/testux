pragma ComponentBehavior: Bound

import QtCore
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

    function startTour() {
        showSection("distros")
        Qt.callLater(() => {
            const page = stack.currentItem
            tour.reveal = item => page.reveal(item)
            tour.start([
                { target: null, title: qsTr("Welcome to Testux"),
                  text: qsTr("Testux lets you try Linux in a window on this PC. Nothing gets installed and Windows stays exactly as it is.") },
                { target: page.quiz, title: qsTr("Not sure where to start?"),
                  text: qsTr("Answer three quick questions here and Testux suggests three distros that fit you.") },
                { target: page.browse, title: qsTr("Or look around yourself"),
                  text: qsTr("All distros are listed here. Click one to read what it is like.") },
                { target: null, title: qsTr("Try it"),
                  text: qsTr("On a distro's page press Try it. Testux downloads it once, checks it and opens Linux in its own window. Close that window when you are done.") },
                { target: sidebar.itemFor("pc"), title: qsTr("Will it run well?"),
                  text: qsTr("This PC checks your memory, graphics and Wi-Fi, so you know what to expect.") },
                { target: sidebar.helpButton, title: qsTr("Need this again?"),
                  text: qsTr("Start this tour again here at any time.") }
            ])
        })
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
            id: sidebar
            sections: window.sections
            onHelpRequested: window.startTour()
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

    TourOverlay {
        id: tour
        onFinished: {
            tourState.done = true
            const page = stack.currentItem
            if (page && page.reveal)
                (page.contentItem as Flickable).contentY = 0
        }
    }

    Settings {
        id: tourState
        category: "tour"

        property bool done: false
    }

    Component.onCompleted: {
        if (BareMetal.postBoot || BareMetal.pending)
            welcomeBack.open()
        else if (!tourState.done)
            startTour()
    }
}
