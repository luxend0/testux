import QtQuick

// Search text and filter choices of the distro list, plus the matching logic.
QtObject {
    property string query: ""
    property string category: ""     // "" = every category
    property list<string> desktops   // empty = any desktop
    property list<string> bases      // empty = any base
    // Yes/no filters: "secureBoot", "liveSession", "nvidiaReady", "rolling", "fixed", "fitsPc".
    property list<string> features
    property int pcRamMb: 0          // 0 = unknown, then "fitsPc" matches every distro
    property var categoryTitles: ({}) // category id -> title, so the search finds "gaming" too

    readonly property bool active: query.trim() !== "" || category !== "" || desktops.length > 0
                                   || bases.length > 0 || features.length > 0

    function clear() {
        query = ""
        category = ""
        desktops = []
        bases = []
        features = []
    }

    function setFeature(key: string, on: bool) {
        const opposite = { rolling: "fixed", fixed: "rolling" }[key] ?? ""
        const rest = features.filter(f => f !== key && !(on && f === opposite))
        features = on ? [...rest, key] : rest
    }

    // `values` with `value` added or removed, for the multi-select menus.
    function toggled(values: list<string>, value: string, on: bool): list<string> {
        const rest = values.filter(v => v !== value)
        return on ? [...rest, value] : rest
    }

    function matches(d: distro): bool {
        const has = key => features.includes(key)
        if (category !== "" && d.category !== category)
            return false
        if (desktops.length > 0 && !desktops.includes(d.desktop))
            return false
        if (bases.length > 0 && !bases.includes(d.base))
            return false
        if ((has("secureBoot") && !d.secureBoot) || (has("liveSession") && !d.liveSession)
                || (has("nvidiaReady") && !d.nvidiaReady))
            return false
        if ((has("rolling") && d.releaseModel !== "rolling") || (has("fixed") && d.releaseModel !== "fixed"))
            return false
        if (has("fitsPc") && pcRamMb > 0 && d.minRamMb > pcRamMb)
            return false
        return matchesQuery(d)
    }

    function matchesQuery(d: distro): bool {
        const words = query.toLowerCase().split(/\s+/).filter(word => word !== "")
        if (words.length === 0)
            return true
        const text = [d.name, d.edition, d.desktop, d.base, Format.baseName(d.base),
                      categoryTitles[d.category] ?? "", d.summary].join(" ").toLowerCase()
        return words.every(word => text.includes(word))
    }
}
