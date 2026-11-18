// Full-screen dashboard over everything; takes the keyboard while open.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: w
    required property var stats
    property bool open: false
    signal close()
    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "qs-pw-dashboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string host: ""
    property bool dnd: false
    Process { running: true; command: ["hostname"]; stdout: StdioCollector { onStreamFinished: w.host = "@" + text.trim() } }
    Process { id: dndQ; command: ["qs", "-c", "fluidity", "ipc", "call", "notifications", "dndStatus"]
              stdout: StdioCollector { onStreamFinished: w.dnd = text.trim() === "on" } }
    SystemClock { id: clock; precision: SystemClock.Hours }
    readonly property string home: Quickshell.env("HOME")
    readonly property var dirs: ({ home: home, downloads: home + "/Downloads", music: home + "/Music",
                                   pictures: home + "/Pictures", wallpapers: home + "/Wallpapers for desktop",
                                   screenshots: home + "/Pictures/Screenshots" })

    DashboardView {
        id: view
        anchors.fill: parent
        profile: Qt.resolvedUrl("profile.png")
        userName: (Quickshell.env("USER") || "").toUpperCase()
        host: w.host
        fortune: w.stats.quote
        dnd: w.dnd
        diskUsed: w.stats.diskUsed
        diskText: Math.round(w.stats.diskUsed * 100) + "%"
        cases: w.stats.cases
        deaths: w.stats.deaths
        uptime: w.stats.uptime
        day: clock.date
        onClosed: w.close()
        onOpenUrl: u => { w.close(); Quickshell.execDetached(["xdg-open", u]) }
        onOpenDir: n => { w.close(); Quickshell.execDetached(["xdg-open", w.dirs[n]]) }
        onToggleDnd: { Quickshell.execDetached(["qs", "-c", "fluidity", "ipc", "call", "notifications", "toggleDnd"]); w.dnd = !w.dnd }
        onScreenshot: { w.close(); Quickshell.execDetached(["bash", "-c", "sleep 5; fluidity-shell screenshot full || grim"]) }
    }
    // your ~/.face when you have one, her profile picture otherwise
    Process { running: true; command: ["test", "-f", w.home + "/.face"]
              onExited: code => { if (code === 0) view.profile = "file://" + w.home + "/.face" } }
    onOpenChanged: if (open) { view.forceActiveFocus(); dndQ.running = true }
}
