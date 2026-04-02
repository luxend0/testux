import QtQuick
import QtQuick.Controls.Basic

Button {
    id: control

    // "primary" for the one main action of a section, "secondary", "quiet" or "danger".
    property string kind: "secondary"

    readonly property bool primary: kind === "primary"
}
