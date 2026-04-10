pragma Singleton

import QtQuick

QtObject {
    function decimal(value: real): string {
        return Number(value).toLocaleString(Qt.locale(), "f", 1)
    }

    // Download sizes, decimal units like browsers and file managers on Windows show them.
    function bytes(value: real): string {
        if (value >= 1e9)
            return qsTr("%1 GB").arg(decimal(value / 1e9))
        return qsTr("%1 MB").arg(Math.round(value / 1e6))
    }

    function megabytes(value: int): string {
        if (value >= 1024)
            return qsTr("%1 GB").arg(decimal(value / 1024))
        return qsTr("%1 MB").arg(value)
    }

    function yesNo(on: bool): string {
        return on ? qsTr("Yes") : qsTr("No")
    }

    function baseName(base: string): string {
        return base === "independent" ? qsTr("Independent") : base
    }

    function releaseModelName(model: string): string {
        return model === "rolling" ? qsTr("Rolling reelase") : qsTr("Fixed releases")
    }
}
