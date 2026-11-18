import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: dock

    // One dock per screen; Variants in shell.qml rebuilds it when a monitor comes back.
    required property ShellScreen modelData
    screen: modelData

    // Geometry, in logical pixels. 48px icons magnifying to 80px matches macOS's default feel.
    // Size and magnification come from state.json (System Settings > Desktop & Dock).
    property int baseSize: 48
    property int magnifySize: 80
    readonly property int maxSize: Math.max(baseSize, magnifySize)
    property bool indicators: true
    readonly property int spacing: 10
    readonly property int padH: 10
    readonly property int padV: 9
    readonly property int edgeGap: 6
    readonly property int sepWidth: 13
    readonly property int shelfHeight: baseSize + padV * 2
    // How far (in resting pixels) from the cursor an icon still grows.
    readonly property real influence: baseSize * 2.6

    // Persisted in state.json.
    property var pins: ["zen", "kitty", "org.gnome.Nautilus", "vesktop", "spotify", "obsidian"]
    property bool autohide: false
    property bool magnify: true
    // Which screen edge the dock sits on: "bottom", "left" or "right" (macOS has no top dock).
    property string position: "bottom"
    readonly property bool vertical: position !== "bottom"

    property bool trashFull: false
    // key -> { count: windows when launched, at: ms timestamp }; an icon bounces while it is here.
    property var launching: ({})

    // Drag-to-reorder state.
    property string dragKey: ""
    property bool removeArmed: false
    readonly property bool dragging: dragKey !== ""
    // Like macOS: Shift-drag the separator to move the dock to another edge (it jumps live),
    // plain-drag the separator to resize the icons.
    property bool moving: false
    property bool resizing: false

    readonly property bool engaged: input.containsMouse || dragging || moving || resizing
    readonly property bool revealed: !autohide || engaged || menu.opened || hideDelay.running

    // Everything is laid out for a bottom dock in "frame" coordinates (u along the dock, v toward the
    // screen edge); the stage transform turns that frame for a left or right dock.
    // Side docks need room beside the icons for the name pill instead of above them.
    readonly property int thickness: edgeGap + padV + maxSize + (vertical ? 250 : 44)
    readonly property real mainLen: vertical ? height : width
    anchors { bottom: true; top: dock.vertical; left: dock.position !== "right"; right: dock.position !== "left" }
    implicitHeight: thickness
    implicitWidth: thickness
    color: "transparent"
    exclusiveZone: autohide ? 0 : edgeGap + shelfHeight
    WlrLayershell.namespace: "qs-dock"
    WlrLayershell.layer: WlrLayer.Top
    mask: Region { item: hitZone }

    onEngagedChanged: if (!engaged && autohide) hideDelay.restart()
    Timer { id: hideDelay; interval: 450 }

    // ---- windows and dock items ------------------------------------------------------

    function isMinimized(w) { return w.workspace.startsWith("special:") }
    function appKey(appId) {
        const e = DesktopEntries.heuristicLookup(appId);
        return e ? e.id : appId;
    }
    function entryFor(key) { return DesktopEntries.byId(key) ?? DesktopEntries.heuristicLookup(key) }
    // Apps the icon theme has no icon for, mapped to one it does.
    readonly property var iconOverrides: ({ "vesktop": "discord", "calendi": "calendar" })

    function iconFor(key) {
        const name = entryFor(key)?.icon ?? key;
        const icon = iconOverrides[name] ?? name;
        if (icon.startsWith("/")) return "file://" + icon;
        return Quickshell.iconPath(icon, "application-x-executable");
    }
    function nameFor(key) { return entryFor(key)?.name ?? key }

    // Titles and focus are read lazily from `top`, so a title change doesn't rebuild the dock.
    readonly property var windows: Hyprland.toplevels.values.map(t => ({
        top: t,
        address: String(t.address),
        appId: t.wayland?.appId ?? t.lastIpcObject?.class ?? "",
        workspace: t.workspace?.name ?? ""
    }))

    readonly property var items: {
        const byKey = {};
        for (const w of windows) {
            if (!w.appId) continue;
            const k = appKey(w.appId);
            (byKey[k] = byKey[k] ?? []).push(w);
        }
        const out = pins.map(k => ({ kind: "app", key: k, pinned: true, windows: byKey[k] ?? [] }));
        const extra = Object.keys(byKey).filter(k => !pins.includes(k));
        if (extra.length) {
            out.push({ kind: "sep", key: "sep:running" });
            for (const k of extra) out.push({ kind: "app", key: k, pinned: false, windows: byKey[k] });
        }
        out.push({ kind: "sep", key: "sep:trash" });
        for (const w of windows.filter(isMinimized))
            out.push({ kind: "min", key: "min:" + w.address, window: w, appKey: appKey(w.appId) });
        out.push({ kind: "downloads", key: "downloads" });
        out.push({ kind: "trash", key: "trash" });
        return out;
    }

    // Item centers when nothing is magnified; magnification is measured against these so
    // icons don't chase the cursor as they grow.
    function restWidthOf(it) { return it.kind === "sep" ? sepWidth : baseSize }
    readonly property var restCenters: {
        let x = 0;
        const c = [];
        for (const it of items) {
            const w = restWidthOf(it);
            c.push(x + w / 2);
            x += w + spacing;
        }
        return c;
    }
    readonly property real restWidth: items.reduce((s, it) => s + restWidthOf(it), 0) + spacing * Math.max(0, items.length - 1)
    readonly property real restStart: (mainLen - restWidth) / 2

    function fromFrame(u, v, w, h) {
        if (position === "left") return Qt.rect(thickness - v - h, u, h, w);
        if (position === "right") return Qt.rect(v, u, h, w);
        return Qt.rect(u, v, w, h);
    }
    function toFrame(x, y) {
        if (position === "left") return Qt.point(y, thickness - x);
        if (position === "right") return Qt.point(y, x);
        return Qt.point(x, y);
    }
    // Where this window sits on its screen (layer surfaces don't report it).
    readonly property real originX: position === "right" ? screen.width - width : 0
    readonly property real originY: screen.height - height
    // The edge closest to a point in window coordinates, for dropping a moved dock.
    function edgeAt(x, y) {
        const gx = originX + x, gy = originY + y;
        const d = { left: gx, right: screen.width - gx, bottom: screen.height - gy };
        return Object.keys(d).reduce((a, b) => d[b] < d[a] ? b : a);
    }
    function endGesture() {
        if (!moving && !resizing) return;
        moving = false;
        resizing = false;
        save();
    }
    function setPosition(p) {
        if (p === position) return;
        position = p;
        save();
    }

    property real strength: magnify && engaged && !dragging && !moving && !resizing ? 1 : 0
    Behavior on strength { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

    function sizeAt(i) {
        const it = items[i];
        if (!it) return baseSize;
        if (it.kind === "sep") return sepWidth;
        const d = Math.abs(input.restX - restCenters[i]);
        if (d >= influence) return baseSize;
        const falloff = (1 + Math.cos(Math.PI * d / influence)) / 2;
        return baseSize + (maxSize - baseSize) * strength * falloff;
    }

    // ---- actions ---------------------------------------------------------------------

    function addr(w) { return w.address.startsWith("0x") ? w.address : "0x" + w.address }
    function focusWindow(w) { Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr(w)}" })`) }
    function restoreNow(w) {
        const ws = Hyprland.focusedWorkspace?.name ?? "1";
        Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = "no_anim", value = "1", window = "address:${addr(w)}" })`);
        Hyprland.dispatch(`hl.dsp.window.move({ workspace = "${ws}", window = "address:${addr(w)}", follow = true })`);
        focusWindow(w);
        Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = "no_anim", value = "unset", window = "address:${addr(w)}" })`);
    }
    function minimizeNow(w) {
        Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = "no_anim", value = "1", window = "address:${addr(w)}" })`);
        Hyprland.dispatch(`hl.dsp.window.move({ workspace = "special:scratchpad", window = "address:${addr(w)}", follow = false })`);
        Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = "no_anim", value = "unset", window = "address:${addr(w)}" })`);
    }

    Genie { id: genie; host: dock }
    onWindowsChanged: genie.prune()

    function iconRectFor(w) {
        const key = appKey(w.appId);
        const index = items.findIndex(it => it.kind === "app" && it.key === key);
        const item = repeater.itemAt(index);
        if (!item) {
            const r = fromFrame(mainLen / 2 - baseSize / 2, thickness - edgeGap - padV - baseSize, baseSize, baseSize);
            return Qt.rect(originX + r.x, originY + r.y, r.width, r.height);
        }
        const a = item.mapToItem(dock.contentItem, 0, 0);
        const b = item.mapToItem(dock.contentItem, item.width, item.height);
        return Qt.rect(originX + Math.min(a.x, b.x), originY + Math.min(a.y, b.y), Math.abs(b.x - a.x), Math.abs(b.y - a.y));
    }
    function restore(w) { genie.start(w, iconRectFor(w), true) }

    function launch(key) {
        const e = entryFor(key);
        if (!e) return;
        e.execute();
        const it = items.find(i => i.key === key);
        launching = Object.assign({}, launching, { [key]: { count: it ? it.windows.length : 0, at: Date.now() } });
    }
    function isBouncing(key, windowCount) {
        const l = launching[key];
        return !!l && windowCount <= l.count;
    }
    // Stop bouncing once the app shows a window, or after 10s if it never does.
    Timer {
        interval: 400; repeat: true
        running: Object.keys(dock.launching).length > 0
        onTriggered: {
            const next = {};
            for (const [k, l] of Object.entries(dock.launching)) {
                const it = dock.items.find(i => i.key === k);
                if (Date.now() - l.at < 10000 && (!it || it.windows.length <= l.count)) next[k] = l;
            }
            dock.launching = next;
        }
    }

    // Open closed apps and focus background windows; clicking the focused app does nothing.
    function activateApp(it) {
        if (it.windows.length === 0) { launch(it.key); return; }
        const visible = it.windows.filter(w => !isMinimized(w));
        if (visible.length === 0) { restore(it.windows[0]); return; }
        const i = visible.findIndex(w => w.top.activated);
        if (i !== -1) return;
        focusWindow(visible[(i + 1) % visible.length]);
    }

    function setPinned(key, on) {
        pins = on ? pins.concat([key]) : pins.filter(k => k !== key);
        save();
    }

    function openTrash() { Quickshell.execDetached(["nautilus", "trash:///"]) }
    function openDownloads() { Quickshell.execDetached(["nautilus", StandardPaths.writableLocation(StandardPaths.DownloadLocation)]) }

    // ---- persistence -----------------------------------------------------------------

    FileView {
        id: stateFile
        path: Quickshell.shellPath("state.json")
        blockLoading: true
        printErrors: false
        // System Settings > Desktop & Dock writes autohide/magnify here (lyric-settings-data).
        watchChanges: true
        // Read only after the reload finished; reading right after reload() got the previous contents,
        // so every Settings change applied one step late (magnification looked dead).
        onFileChanged: reload()
        onLoaded: dock.loadState(false)
    }
    Component.onCompleted: loadState(true)
    function loadState(first) {
        try {
            const s = JSON.parse(stateFile.text());
            if (Array.isArray(s.pins) && JSON.stringify(s.pins) !== JSON.stringify(pins)) pins = s.pins;
            autohide = !!s.autohide;
            magnify = s.magnify ?? true;
            baseSize = Math.min(96, Math.max(32, s.size ?? 48));
            magnifySize = Math.min(128, s.magnifySize ?? 80);
            indicators = s.indicators ?? true;
            position = ["left", "right", "bottom"].includes(s.position) ? s.position : "bottom";
        } catch (e) {
            if (first) save();
        }
    }
    // Write only what the dock itself changes (pins, hiding, magnify on/off, edge, separator-drag size) on top of what is in the file now,
    // so it never overwrites the size/magnification/indicators that System Settings wrote.
    function save() {
        let cur = {};
        try { cur = JSON.parse(stateFile.text()) || {} } catch (e) {}
        stateFile.setText(JSON.stringify(Object.assign(cur, { pins, autohide, magnify, position, size: baseSize }), null, 2) + "\n");
    }

    Process {
        id: trashCheck
        command: ["sh", "-c", "ls -A \"$HOME/.local/share/Trash/files\" 2>/dev/null | head -c1"]
        stdout: StdioCollector { onStreamFinished: dock.trashFull = text.length > 0 }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: trashCheck.running = true }

    // ---- menus -----------------------------------------------------------------------

    MacMenu { id: menu }

    function menuFor(it) {
        if (it.kind === "downloads")
            return [{ text: "Open Downloads", action: openDownloads }];
        if (it.kind === "trash")
            return [
                { text: "Open", action: openTrash },
                { separator: true },
                { text: "Empty Trash", enabled: trashFull, action: () => Quickshell.execDetached(["gio", "trash", "--empty"]) }
            ];
        if (it.kind === "min")
            return [
                { text: "Open", action: () => restore(it.window) },
                { text: "Close", action: () => it.window.top.wayland?.close() }
            ];
        if (it.kind === "sep")
            return [
                { text: autohide ? "Turn Hiding Off" : "Turn Hiding On", action: () => { autohide = !autohide; save(); } },
                { text: magnify ? "Turn Magnification Off" : "Turn Magnification On", action: () => { magnify = !magnify; save(); } },
                { separator: true },
                { text: "Position on Screen", submenu: [
                    { text: "Left", checked: position === "left", action: () => setPosition("left") },
                    { text: "Bottom", checked: position === "bottom", action: () => setPosition("bottom") },
                    { text: "Right", checked: position === "right", action: () => setPosition("right") }
                ] }
            ];

        const out = [];
        for (const w of it.windows)
            out.push({ text: w.top.title || nameFor(it.key), checked: w.top.activated,
                       action: () => isMinimized(w) ? restore(w) : focusWindow(w) });
        if (out.length) out.push({ separator: true });
        const e = entryFor(it.key);
        if (it.windows.length) out.push({ text: "New Window", action: () => e?.execute() });
        for (const a of (e?.actions ?? []))
            out.push({ text: a.name, action: () => a.execute() });
        out.push({ separator: true });
        out.push({ text: "Options", submenu: [
            { text: "Keep in Dock", checked: it.pinned, action: () => setPinned(it.key, !it.pinned) }
        ] });
        if (it.windows.length) {
            out.push({ separator: true });
            out.push({ text: "Quit", action: () => it.windows.forEach(w => w.top.wayland?.close()) });
        } else {
            out.push({ text: "Open", action: () => launch(it.key) });
        }
        return out;
    }

    // ---- input -----------------------------------------------------------------------

    // Input only lands inside this area; the rest of the full-width layer is click-through.
    Item {
        id: hitZone
        readonly property real v: !dock.revealed ? dock.thickness - 2
           : dock.engaged ? shelf.y - (dock.maxSize - dock.baseSize) - 6
           : shelf.y
        readonly property rect r: dock.fromFrame(shelf.x, v, shelf.width, dock.thickness - v)
        x: r.x
        y: r.y
        width: r.width
        height: r.height
    }

    // u is a frame coordinate along the dock.
    function indexAt(u) {
        const px = u - iconsRow.x;
        for (let i = 0; i < repeater.count; i++) {
            const d = repeater.itemAt(i);
            if (d && px >= d.x - spacing / 2 && px < d.x + d.width + spacing / 2) return i;
        }
        return -1;
    }

    // While Shift-dragging, jump to the edge under the cursor, but not faster than the window can follow.
    Timer { id: jumpCooldown; interval: 250 }
    function maybeJump(x, y) {
        if (jumpCooldown.running) return;
        const e = edgeAt(x, y);
        const gx = originX + x, gy = originY + y;
        const near = e === "left" ? gx < screen.width / 4
                   : e === "right" ? screen.width - gx < screen.width / 4
                   : screen.height - gy < screen.height / 4;
        if (e !== position && near) { position = e; jumpCooldown.restart(); }
    }

    MouseArea {
        id: input
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        readonly property bool overSep: dock.items[hoverIndex]?.kind === "sep"
        cursorShape: dock.moving ? Qt.ClosedHandCursor
                   : dock.resizing || overSep ? (dock.vertical ? Qt.SizeHorCursor : Qt.SizeVerCursor)
                   : Qt.ArrowCursor

        // Mouse positions below are frame coordinates (see fromFrame).
        property real restX: -10000
        property real hoverU: -10000
        property int pressIndex: -1
        property real pressU: 0
        property real pressV: 0
        property real pressDepth: 0     // cursor distance from the screen edge at press, in pixels
        property int pressSize: 48
        readonly property int hoverIndex: containsMouse && !dock.dragging && !dock.moving && !dock.resizing ? dock.indexAt(hoverU) : -1

        onPositionChanged: (m) => {
            const f = dock.toFrame(m.x, m.y);
            hoverU = f.x;
            restX = f.x - dock.restStart;
            if (!pressed) return;
            if (dock.moving) { dock.maybeJump(m.x, m.y); return; }
            if (dock.resizing) {
                // Away from the edge grows the icons, toward it shrinks them.
                const depth = dock.thickness - f.y;
                dock.baseSize = Math.round(Math.min(96, Math.max(32, pressSize + depth - pressDepth)));
                return;
            }
            const it = dock.items[pressIndex];
            if (!dock.dragging && Math.hypot(f.x - pressU, f.y - pressV) > 6) {
                genie.cancelPreparation();
                if (it?.kind === "sep" && (m.buttons & Qt.LeftButton)) {
                    if (m.modifiers & Qt.ShiftModifier) dock.moving = true;
                    else dock.resizing = true;
                    return;
                }
                if (it?.kind === "app" && it.pinned) dock.dragKey = it.key;
            }
            if (!dock.dragging) return;

            // Slide the dragged pin into whichever pin slot the cursor is over.
            const at = dock.indexAt(f.x);
            const target = Math.max(0, Math.min(dock.pins.length - 1, at < 0
                ? (f.x < shelf.x + shelf.width / 2 ? 0 : dock.pins.length - 1)
                : at));
            const from = dock.pins.indexOf(dock.dragKey);
            if (from !== -1 && target !== from) {
                const p = dock.pins.slice();
                p.splice(target, 0, p.splice(from, 1)[0]);
                dock.pins = p;
            }
            dock.removeArmed = f.y < shelf.y - (dock.maxSize - dock.baseSize) - 10;
        }
        onExited: if (!dock.dragging && !dock.moving && !dock.resizing) { restX = -10000; hoverU = -10000; }
        onPressed: (m) => {
            const f = dock.toFrame(m.x, m.y);
            pressIndex = dock.indexAt(f.x);
            pressU = f.x;
            pressV = f.y;
            pressDepth = dock.thickness - f.y;
            pressSize = dock.baseSize;
            const it = dock.items[pressIndex];
            if (m.button !== Qt.LeftButton) return;
            const w = it?.kind === "app" ? it.windows.find(w => w.top.activated && !dock.isMinimized(w)) : null;
            if (w) genie.start(w, dock.iconRectFor(w), false, true);
        }
        onCanceled: { dock.endGesture(); genie.cancelPreparation(); }
        onReleased: (m) => {
            if (dock.moving || dock.resizing) {
                dock.endGesture();
                pressIndex = -1;
                return;
            }
            if (dock.dragging) {
                if (dock.removeArmed) dock.pins = dock.pins.filter(k => k !== dock.dragKey);
                dock.save();
                dock.dragKey = "";
                dock.removeArmed = false;
                pressIndex = -1;
                return;
            }
            const i = dock.indexAt(dock.toFrame(m.x, m.y).x);
            const it = dock.items[i];
            if (i !== pressIndex || !it) { genie.cancelPreparation(); return; }
            if (m.button === Qt.RightButton) {
                const d = repeater.itemAt(i);
                // Inner edge of the icon (the side facing the middle of the screen).
                const p = d.mapToItem(dock.contentItem, d.width / 2, d.height - d.width);
                if (dock.position === "left") menu.open(dock, p.x + 8, p.y - 14, dock.menuFor(it), false);
                else if (dock.position === "right") menu.open(dock, p.x - 8, p.y - 14, dock.menuFor(it), false, true);
                else menu.open(dock, p.x, p.y - 6, dock.menuFor(it), true);
            } else if (it.kind === "app") dock.activateApp(it);
            else if (it.kind === "min") dock.restore(it.window);
            else if (it.kind === "trash") dock.openTrash();
            else if (it.kind === "downloads") dock.openDownloads();
        }
    }

    // ---- visuals ---------------------------------------------------------------------

    Item {
        id: stage
        width: dock.mainLen
        height: dock.thickness
        // Slide toward the edge to hide, then turn the bottom-dock frame onto the dock's edge.
        transform: [
            Translate {
                y: dock.revealed ? 0 : dock.shelfHeight + dock.edgeGap + 4
                Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            },
            Rotation { angle: dock.vertical ? 90 : 0 },
            Translate { x: dock.vertical ? dock.thickness : 0 },
            Scale { origin.x: dock.thickness / 2; xScale: dock.position === "right" ? -1 : 1 }
        ]

        // Frosted shelf; Hyprland blurs what's behind it (layer rule on "qs-dock").
        DockShelf {
            id: shelf
            width: iconsRow.width + dock.padH * 2
            height: dock.shelfHeight
            x: (dock.mainLen - width) / 2
            y: dock.thickness - dock.edgeGap - height
            opacity: dock.moving ? 0.6 : 1
        }

        Row {
            id: iconsRow
            x: shelf.x + dock.padH
            y: shelf.y + dock.padV + dock.baseSize - dock.maxSize
            height: dock.maxSize
            spacing: dock.spacing

            Repeater {
                id: repeater
                model: dock.items
                DockItem { host: dock }
            }
        }
    }

    // Drawn outside the stage so they stay upright and in window coordinates on any edge.
    // App name pill beside the hovered icon, on the screen-middle side.
    Rectangle {
        id: tooltip
        readonly property var target: input.hoverIndex >= 0 ? repeater.itemAt(input.hoverIndex) : null
        readonly property var item: input.hoverIndex >= 0 ? dock.items[input.hoverIndex] : null
        visible: !!target && !!item && item.kind !== "sep" && !menu.opened && !dock.dragging && !dock.moving && !peek.visible
        // The hovered icon's square, in window coordinates.
        readonly property rect icon: target ? dock.fromFrame(iconsRow.x + target.x, iconsRow.y + iconsRow.height - target.width,
                                                              target.width, target.width) : Qt.rect(0, 0, 0, 0)
        width: Math.min(label.implicitWidth, 220) + 20
        height: 24
        radius: 7
        color: Qt.rgba(0.04, 0.04, 0.04, 0.82)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.14)
        x: dock.position === "left" ? icon.x + icon.width + 10
         : dock.position === "right" ? icon.x - width - 10
         : icon.x + icon.width / 2 - width / 2
        y: dock.vertical ? icon.y + icon.height / 2 - height / 2 : icon.y - height - 10

        Text {
            id: label
            anchors.centerIn: parent
            width: Math.min(implicitWidth, 220)
            elide: Text.ElideRight
            color: "white"
            font.pixelSize: 13
            font.family: "Inter"
            text: !tooltip.item ? ""
                : tooltip.item.kind === "trash" ? "Trash"
                : tooltip.item.kind === "downloads" ? "Downloads"
                : tooltip.item.kind === "min" ? (tooltip.item.window.top.title || dock.nameFor(tooltip.item.appKey))
                : dock.nameFor(tooltip.item.key)
        }
    }

    // ---- window previews on hover (System Settings > Toolkit > Dock Previews) --------------------
    // A separate layer above the hovered app: live thumbnails of its windows; click one to go to it.
    FileView {
        id: toolkitState
        path: Quickshell.env("HOME") + "/.local/state/lyric/toolkit.json"
        watchChanges: true
        onFileChanged: reload()
    }
    readonly property var toolkitCfg: { try { return JSON.parse(toolkitState.text() || "{}") } catch (e) { return {} } }
    readonly property bool previewsOn: (toolkitCfg.enabled?.dockpreview ?? true)
    readonly property int previewDelay: toolkitCfg.dockpreview?.delay ?? 500
    property var peekItem: null
    property rect peekIcon: Qt.rect(0, 0, 0, 0)
    property bool peekHover: false
    readonly property var hoverApp: input.hoverIndex >= 0 && dock.items[input.hoverIndex]?.kind === "app"
                                    && (dock.items[input.hoverIndex].windows?.length ?? 0) > 0 ? dock.items[input.hoverIndex] : null
    onHoverAppChanged: {
        if (hoverApp && previewsOn && !menu.opened && !dragging) { peekShow.restart(); if (peek.visible) peekShow.triggered() }
        else { peekShow.stop(); peekHide.restart() }
    }
    Timer { id: peekShow; interval: dock.previewDelay
            onTriggered: { if (!dock.hoverApp) return; peekHide.stop(); dock.peekItem = dock.hoverApp; dock.peekIcon = tooltip.icon; peek.visible = true } }
    Timer { id: peekHide; interval: 350; onTriggered: if (!dock.peekHover && !dock.hoverApp) { peek.visible = false; dock.peekItem = null } }

    PanelWindow {
        id: peek
        visible: false
        color: "transparent"
        screen: dock.screen
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "qs-lyric-dock-peek"
        WlrLayershell.layer: WlrLayer.Overlay
        readonly property var wins: dock.peekItem?.windows ?? []
        implicitWidth: Math.max(1, peekRow.implicitWidth + 20)
        implicitHeight: 160
        anchors { bottom: dock.position === "bottom"; left: dock.position !== "right"; right: dock.position === "right"; top: dock.vertical }
        margins {
            bottom: dock.position === "bottom" ? dock.thickness - 40 : 0
            left: dock.position === "bottom" ? Math.max(4, Math.min(dock.screen.width - implicitWidth - 4, dock.originX + dock.peekIcon.x + dock.peekIcon.width / 2 - implicitWidth / 2))
                : dock.position === "left" ? dock.peekIcon.x + dock.peekIcon.width + 12 : 0
            right: dock.position === "right" ? dock.thickness - dock.peekIcon.x + 12 : 0
            top: dock.vertical ? Math.max(4, dock.peekIcon.y + dock.peekIcon.height / 2 - 80) : 0
        }
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Qt.rgba(0.1, 0.1, 0.11, 0.85)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.14)
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: { dock.peekHover = containsMouse; if (!containsMouse) peekHide.restart() }
            }
            Row {
                id: peekRow
                x: 10; y: 10
                spacing: 10
                Repeater {
                    model: peek.wins
                    Item {
                        id: pw
                        required property var modelData
                        width: 190; height: 140
                        Rectangle { anchors.fill: parent; radius: 10; color: pm.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent" }
                        ScreencopyView {
                            id: sv
                            x: 5; y: 5; width: 180; height: 110
                            captureSource: peek.visible ? pw.modelData.top.wayland : null
                            live: true
                            constraintSize: Qt.size(180, 110)
                        }
                        Text { x: 6; y: 120; width: parent.width - 12; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter
                               text: pw.modelData.top.title; color: "white"; font.family: "Inter"; font.pixelSize: 11 }
                        MouseArea {
                            id: pm
                            anchors.fill: parent
                            hoverEnabled: true
                            onContainsMouseChanged: if (containsMouse) dock.peekHover = true
                            onClicked: {
                                peek.visible = false; dock.peekItem = null;
                                dock.focusWindow(pw.modelData);
                            }
                        }
                    }
                }
            }
        }
    }

    // The icon under the cursor while dragging a pin.
    Image {
        visible: dock.dragging
        width: dock.baseSize * 1.1
        height: width
        x: input.mouseX - width / 2
        y: input.mouseY - height / 2
        source: dock.dragging ? dock.iconFor(dock.dragKey) : ""
        sourceSize: Qt.size(dock.maxSize * 2, dock.maxSize * 2)
        opacity: dock.removeArmed ? 0.5 : 0.9
        smooth: true
        mipmap: true

        Rectangle {
            visible: dock.removeArmed
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.top; bottomMargin: 4 }
            width: removeLabel.implicitWidth + 16
            height: 22
            radius: 7
            color: Qt.rgba(0.04, 0.04, 0.04, 0.82)
            Text { id: removeLabel; anchors.centerIn: parent; text: "Remove"; color: "white"; font.pixelSize: 12 }
        }
    }
}
