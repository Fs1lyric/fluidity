import QtQuick

// One macOS Tahoe menu, dark appearance. Plain QtQuick so it also renders offscreen
// (~/claude/archy-cleanup/tahoe/render). Shared by the menu bar and the dock (dock/ symlinks it).
//
// Measured from Tahoe screenshots: 12 px card corners, 5 px inset, 24 px rows, 11 px separator
// blocks, columns at 11 (check), 25 (icon, or title when no row has an icon) and 44 (title after
// icons), shortcuts right-aligned 14 px from the edge, 13 px text. The highlight is an
// accent-blue rounded rect inset 5 px, concentric with the card (12 - 5 = 7 px corners).
//
// Entry: { text, action?, enabled?, checked?, icon? (image url), shortcut? ("⇧⌘N"), submenu? [entries] }
//        or { separator: true }.
// Status-menu extras (menu bar items): detail? (grey text on the right), inert? (normal ink but not
// clickable: information rows), meter? (0-100: a 40 px row with a level bar under the text; meterColor?).
FocusScope {
    id: view

    property var entries: []
    property int current: -1

    signal activated(int index)
    signal hoveredRow(int index)
    signal dismiss()
    signal sideways(int step)

    readonly property color textColor: Qt.rgba(1, 1, 1, 0.88)
    readonly property color secondaryColor: Qt.rgba(1, 1, 1, 0.45)
    readonly property color disabledColor: Qt.rgba(1, 1, 1, 0.25)
    readonly property color accent: "#0a84ff"

    readonly property int inset: 5
    readonly property int rowHeight: 24
    readonly property int sepHeight: 11
    readonly property int keyColumn: 12
    readonly property bool hasIcons: entries.some(e => !!e.icon)
    readonly property bool hasSubmenus: entries.some(e => !!e.submenu)
    readonly property bool hasShortcuts: entries.some(e => !!e.shortcut)
    readonly property int textX: hasIcons ? 44 : 25

    // "⇧⌘N" -> modifiers "⇧⌘" and key "N"; macOS lines the keys up in their own column.
    function modsOf(s) { return s ? s.slice(0, -1) : "" }
    function keyOf(s) { return s ? s.slice(-1) : "" }
    function usable(e) { return !!e && !e.separator && !e.inert && (e.enabled ?? true) }

    readonly property real maxText: entries.reduce((m, e) => e.separator ? m : Math.max(m, fm.advanceWidth(e.text ?? "")), 0)
    readonly property real maxMods: entries.reduce((m, e) => e.shortcut ? Math.max(m, fm.advanceWidth(modsOf(e.shortcut))) : m, 0)
    readonly property bool hasMeters: entries.some(e => e.meter !== undefined)
    readonly property real maxDetail: entries.reduce((m, e) => e.detail ? Math.max(m, fm.advanceWidth(e.detail)) : m, 0)
    readonly property real tail: hasShortcuts ? 37 + maxMods + 3 + keyColumn + 14
                               : hasSubmenus ? 37 + 6 + 14
                               : maxDetail > 0 ? 24 + maxDetail + 14 : 25

    implicitWidth: Math.max(hasMeters ? 280 : 160, Math.ceil(textX + maxText + tail))
    implicitHeight: list.implicitHeight + inset * 2

    function rowY(i) {
        const r = rows.itemAt(i);
        return r ? r.y + list.y : 0;
    }
    function step(d) {
        const n = entries.length;
        let i = current < 0 && d < 0 ? n : current;
        for (let k = 0; k < n; k++) {
            i = (i + d + n) % n;
            if (usable(entries[i])) { current = i; return; }
        }
    }

    Keys.onUpPressed: step(-1)
    Keys.onDownPressed: step(1)
    Keys.onReturnPressed: if (current >= 0) activated(current)
    Keys.onEnterPressed: if (current >= 0) activated(current)
    Keys.onSpacePressed: if (current >= 0) activated(current)
    Keys.onEscapePressed: dismiss()
    Keys.onLeftPressed: sideways(-1)
    Keys.onRightPressed: sideways(1)

    FontMetrics { id: fm; font.family: "Inter"; font.pixelSize: 13 }

    // Glass card. Hyprland blurs what is behind it (blur_popups on the owning layer).
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(0.118, 0.118, 0.125, 0.80)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.14)
    }

    Column {
        id: list
        x: 0
        y: view.inset
        width: view.width

        Repeater {
            id: rows
            model: view.entries

            Item {
                id: row
                required property var modelData
                required property int index
                readonly property bool sep: modelData.separator === true
                readonly property bool live: view.usable(modelData)
                readonly property bool inert: modelData.inert === true
                readonly property bool isMeter: !sep && modelData.meter !== undefined
                readonly property bool lit: live && view.current === index
                readonly property color ink: lit ? "white" : live || inert ? view.textColor : view.disabledColor

                width: list.width
                height: sep ? view.sepHeight : isMeter ? 40 : view.rowHeight

                Rectangle {
                    visible: row.sep
                    x: 14
                    y: 5
                    width: parent.width - 28
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.12)
                }

                Rectangle {
                    visible: row.lit
                    x: view.inset
                    width: parent.width - view.inset * 2
                    height: parent.height
                    radius: 7
                    color: view.accent
                }

                Canvas {
                    id: check
                    visible: !row.sep && row.modelData.checked === true
                    x: 10
                    width: 11
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    property color ink: row.ink
                    onInkChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d");
                        c.reset();
                        c.strokeStyle = ink;
                        c.lineWidth = 1.7;
                        c.lineCap = "round";
                        c.lineJoin = "round";
                        c.beginPath();
                        c.moveTo(1.2, 5.2);
                        c.lineTo(4.2, 8.4);
                        c.lineTo(9.8, 1.2);
                        c.stroke();
                    }
                }

                // WhiteSur's symbolic icons are already light grey (#dedede), the menu's ink.
                Image {
                    visible: !row.sep && !!row.modelData.icon
                    x: 25
                    width: 15
                    height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    source: row.sep ? "" : (row.modelData.icon ?? "")
                    sourceSize: Qt.size(30, 30)
                    opacity: row.live ? 1 : 0.3
                    smooth: true
                }

                Text {
                    id: title
                    visible: !row.sep
                    x: view.textX
                    y: row.isMeter ? 4 : (parent.height - height) / 2
                    text: row.sep ? "" : (row.modelData.text ?? "")
                    color: row.ink
                    font.family: "Inter"
                    font.pixelSize: 13
                }

                // Shortcut: modifiers right-aligned against the key column.
                Text {
                    visible: !row.sep && !!row.modelData.shortcut
                    anchors.right: key.left
                    anchors.rightMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                    text: view.modsOf(row.modelData.shortcut)
                    color: row.lit ? "white" : row.live ? view.secondaryColor : view.disabledColor
                    font.family: "Inter"
                    font.pixelSize: 13
                }
                Text {
                    id: key
                    visible: !row.sep && !!row.modelData.shortcut
                    x: parent.width - 14 - view.keyColumn
                    width: view.keyColumn
                    anchors.verticalCenter: parent.verticalCenter
                    text: view.keyOf(row.modelData.shortcut)
                    color: row.lit ? "white" : row.live ? view.secondaryColor : view.disabledColor
                    font.family: "Inter"
                    font.pixelSize: 13
                }

                Text {
                    visible: !row.sep && !!row.modelData.detail
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    y: title.y
                    text: row.sep ? "" : (row.modelData.detail ?? "")
                    color: row.lit ? "white" : view.secondaryColor
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.features: { "tnum": 1 }
                }

                // Level bar: track plus fill, the fill tinted by meterColor (default the accent).
                Rectangle {
                    visible: row.isMeter
                    x: view.textX
                    y: 26
                    width: parent.width - view.textX - 14
                    height: 6
                    radius: 3
                    color: Qt.rgba(1, 1, 1, 0.12)
                    Rectangle {
                        width: Math.max(parent.height, parent.width * Math.min(100, Math.max(0, row.modelData.meter ?? 0)) / 100)
                        height: parent.height
                        radius: 3
                        visible: (row.modelData.meter ?? 0) > 0
                        color: row.modelData.meterColor ?? view.accent
                    }
                }

                Canvas {
                    visible: !row.sep && !!row.modelData.submenu
                    x: parent.width - 14 - width
                    width: 6
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    property color ink: row.ink
                    onInkChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d");
                        c.reset();
                        c.strokeStyle = ink;
                        c.lineWidth = 1.6;
                        c.lineCap = "round";
                        c.lineJoin = "round";
                        c.beginPath();
                        c.moveTo(1, 1);
                        c.lineTo(5, 5);
                        c.lineTo(1, 9);
                        c.stroke();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !row.sep
                    onEntered: {
                        view.current = row.live ? row.index : -1;
                        view.hoveredRow(row.index);
                    }
                    onExited: if (view.current === row.index && !row.modelData.submenu) view.current = -1
                    onClicked: if (row.live) view.activated(row.index)
                }
            }
        }
    }
}
