pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ApplicationWindow {
    id: window

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

    Component {
        id: thisPcPage

        ThisPcPage {}
    }
}
