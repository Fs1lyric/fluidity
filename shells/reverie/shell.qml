// Reverie: chocycat's "[awesome] made with my own two paws!" (r/unixporn 1pw76sa, github chocycat/dotfiles +
// chocycat/polestar) rebuilt in Quickshell: the plum palette, the slim bar, Polestar's big desktop clock and its
// Quick Search. Keyboard-only: Super+F1 opens Quick Search with the keyboard grabbed (type, ↑↓, Enter, Tab for
// Windows / Clipboard, Esc), Super+` hides the bar, Super+Esc is the power menu. fluidity-theme starts it.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    property int tab: 0
    property string query: ""
    property var clips: []
    FontLoader { source: "Figtree-Regular.ttf" }
    FontLoader { source: "Figtree-Medium.ttf" }
    FontLoader { source: "Figtree-SemiBold.ttf" }
    Sys { id: live }

    Process { id: readClips; command: ["cliphist", "list"]
              stdout: StdioCollector { onStreamFinished: root.clips = text.split("\n").filter(l => l).slice(0, 200).map(l => { const t = l.indexOf("\t"); return { id: l.slice(0, t), text: l.slice(t + 1) } }) } }
    onOpenChanged: if (open) readClips.running = true

    // maths only: digits, operators, brackets, dots, spaces; anything else is not a calculation
    function calc(q) {
        if (!/^[0-9+\-*/().%^ ]+$/.test(q) || !/[0-9]/.test(q) || !/[+\-*/%^]/.test(q)) return ""
        try { const v = Function("return (" + q.replace(/\^/g, "**") + ")")(); return isFinite(v) ? String(+v.toFixed(10)) : "" } catch (e) { return "" }
    }
    readonly property var commands: [
        { title: "Lock", glyph: "\u{F033E}", act: "lock" }, { title: "Power menu", glyph: "\u{F0425}", act: "power" },
        { title: "Toggle Wi-Fi", glyph: "\u{F05A9}", act: "wifi" }, { title: "Toggle Bluetooth", glyph: "\u{F00AF}", act: "bt" },
        { title: "Mute", glyph: "\u{F075F}", act: "mute" }, { title: "Screenshot area", glyph: "\u{F0104}", act: "shot" },
        { title: "Stay awake", glyph: "\u{F0176}", act: "caffeine" }, { title: "Settings", glyph: "\u{F0493}", act: "settings" }]
    function hit(t, q) { return t.toLowerCase().indexOf(q) >= 0 }
    readonly property var results: {
        const q = query.trim().toLowerCase()
        if (tab === 1) return Hyprland.toplevels.values.filter(w => !q || hit(w.title || "", q) || hit(w.lastIpcObject?.class ?? "", q))
                         .map(w => ({ group: "Windows", title: w.title || "untitled", sub: w.lastIpcObject?.class ?? "", glyph: "\u{F05B6}", win: w }))
        if (tab === 2) return clips.filter(c => !q || hit(c.text, q)).map(c => ({ group: "Clipboard", title: c.text, sub: "#" + c.id, glyph: "\u{F014C}", clip: c.id }))
        const apps = !q ? [] : DesktopEntries.applications.values.filter(a => hit(a.name, q) || hit(a.genericName ?? "", q))
                         .slice(0, 6).map(a => ({ group: "Applications", title: a.name, sub: a.genericName ?? "", glyph: "\u{F003B}", app: a }))
        const cmds = commands.filter(c => !q || hit(c.title, q)).map(c => ({ group: "Commands", title: c.title, sub: "", glyph: c.glyph, act: c.act }))
        const web = q ? [{ group: "Web", title: "Search \"" + query.trim() + "\" on the web", sub: "", glyph: "\u{F059F}", url: "https://duckduckgo.com/?q=" + encodeURIComponent(query.trim()) }] : []
        return apps.concat(cmds).concat(web)
    }
    function runItem(r) {
        if (r.app) r.app.execute()
        else if (r.win) { const a = String(r.win.address); Hyprland.dispatch(`hl.dsp.focus({ window = "address:${a.startsWith("0x") ? a : "0x" + a}" })`) }
        else if (r.clip) live.act("exec", ["sh", "-c", "cliphist decode " + r.clip.replace(/[^0-9]/g, "") + " | wl-copy"])
        else if (r.url) live.act("url", r.url)
        else if (r.act) live.act(r.act, null)
        root.open = false
    }

    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-reverie-bar"
                BarView { anchors.fill: parent; sys: live }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; left: true }
                margins { bottom: 80; left: 96 }
                implicitWidth: clock.implicitWidth; implicitHeight: clock.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-reverie-clock"
                WlrLayershell.layer: WlrLayer.Bottom
                ClockView { id: clock; now: live.now }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                anchors { top: true; left: true }
                margins { top: 46; left: 24 }
                implicitWidth: search.implicitWidth; implicitHeight: 560
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-reverie-search"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                SearchView { id: search; width: implicitWidth; height: implicitHeight
                             onTabChanged: root.tab = tab
                             onQueryChanged: root.query = query
                             results: root.results; answer: root.calc(root.query.trim())
                             onRun: r => root.runItem(r); onClose: root.open = false }
                onVisibleChanged: if (visible) { search.tab = 0; search.query = ""; search.focusInput() }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
