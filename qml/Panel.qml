import QtQuick
import QtQuick.Controls.Basic

// White rounded surface that groups one topic on a page.
Pane {
    padding: Theme.gapXl

    background: Rectangle {
        color: Theme.surface
        radius: Theme.radiusLarge
        border.color: Theme.border
    }
}
