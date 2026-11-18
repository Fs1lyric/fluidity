// Auto-hiding dock: a 1 px strip on the bottom edge shows it, it hides 0.5 s after the mouse leaves.
// One item per app class (pinned first, then whatever is open). Click: launch / focus / cycle; middle: close.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Scope {
    id: sc
    required property var screen
    property bool shown: false
    // her pinned launchers (browser, chat, editor, mail) mapped to this machine's apps
    readonly property var pinned: [["zen", "zen-browser"], ["vesktop", "vesktop"], ["calendio", "calendio"], ["obsidian", "obsidian"]]
    function clsOf(t) { return (t.wayland?.appId ?? t.lastIpcObject?.class ?? "").toString() }
    readonly property var items: {
        const wins = Hyprland.toplevels.values, act = Hyprland.activeToplevel, seen = {}, out = [];
        for (const p of pinned) { seen[p[0]] = true; out.push({ cls: p[0], open: false, focused: false }) }
        for (const t of wins) {
            const c = clsOf(t).toLowerCase(); if (!c) continue;
            let it = out.find(o => c.indexOf(o.cls) >= 0);
            if (!it) { it = { cls: c, open: false, focused: false }; out.push(it) }
            it.open = true; if (t === act) it.focused = true;
        }
        return out;
    }
    function addr(t) { const a = String(t.address); return a.startsWith("0x") ? a : "0x" + a; }
    function activate(cls) {
        const wins = Hyprland.toplevels.values.filter(t => clsOf(t).toLowerCase().indexOf(cls) >= 0);
        if (!wins.length) {
            const p = pinned.find(p => p[0] === cls);
            if (p) Quickshell.execDetached(["uwsm-app", "--", p[1]]);
            return;
        }
        const i = wins.indexOf(Hyprland.activeToplevel), next = wins[(i + 1) % wins.length];
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:${addr(next)}" })`);
    }
    function closeClass(cls) {
        for (const t of Hyprland.toplevels.values)
            if (clsOf(t).toLowerCase().indexOf(cls) >= 0) Hyprland.dispatch(`hl.dsp.window.close({ window = "address:${addr(t)}" })`);
    }

    Timer { id: hide; interval: 500; onTriggered: sc.shown = false }

    PanelWindow {
        screen: sc.screen
        anchors.bottom: true
        implicitWidth: 900; implicitHeight: 1
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "qs-pw-dock-edge"
        WlrLayershell.layer: WlrLayer.Overlay
        MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: { hide.stop(); sc.shown = true } }
    }

    PanelWindow {
        screen: sc.screen
        visible: sc.shown
        anchors.bottom: true
        implicitWidth: view.implicitWidth; implicitHeight: view.implicitHeight + 8
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "qs-pw-dock"
        WlrLayershell.layer: WlrLayer.Overlay
        HoverHandler { onHoveredChanged: hovered ? hide.stop() : hide.restart() }
        DockView { id: view; anchors.top: parent.top; items: sc.items
                   onActivate: c => sc.activate(c); onCloseClass: c => sc.closeClass(c) }
    }
}
