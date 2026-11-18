// His eww dashboard over a blurred, dimmed desktop (the qs-lum-* namespace gets Hyprland's blur rule).
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "Pal.js" as P
import "Power.js" as Pw

PanelWindow {
    id: w
    required property var stats
    property bool open: false
    signal close()
    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "qs-lum-noidea-dashboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string home: Quickshell.env("HOME")
    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property bool night: { const h = clock.date.getHours(); return h < 6 || h >= 19 }
    readonly property var wx: P.weather(w.stats.weatherCond, night)
    readonly property var quotes: [["Wisdom begins in wonder.", "Socrates"], ["Simplicity is the ultimate sophistication.", "Leonardo da Vinci"],
        ["The only way to do great work is to love what you do.", "Steve Jobs"], ["Talk is cheap. Show me the code.", "Linus Torvalds"],
        ["Well done is better than well said.", "Benjamin Franklin"]]
    property int q: 0
    readonly property var dirs: ({ Desktop: home + "/Desktop", Documents: home + "/Documents", Downloads: home + "/Downloads",
                                   Bin: home + "/.local/bin", Dwm: home + "/.config/hypr", Repos: home + "/claude" })

    DashboardView {
        id: view
        anchors.fill: parent
        profile: Qt.resolvedUrl("profile.png")
        name: { const u = Quickshell.env("USER") || ""; return u.charAt(0).toUpperCase() + u.slice(1) }
        subtitle: "That Cat"
        weatherGlyph: w.wx[0]
        temp: w.stats.weatherTemp ? w.stats.weatherTemp + "°C" : "—"
        cond: w.stats.weatherCond || "—"
        line1: w.wx[1]
        line2: w.wx[2]
        quote: w.quotes[w.q][0]
        author: w.quotes[w.q][1]
        onClosed: w.close()
        onPower: a => { w.close(); Quickshell.execDetached(Pw.commands[a]) }
        onOpenDir: n => { w.close(); Quickshell.execDetached(["xdg-open", w.dirs[n]]) }
        onSearch: { w.close(); Quickshell.execDetached(["bash", "-c", "pkill fuzzel || fuzzel"]) }
        onScreenshot: { w.close(); Quickshell.execDetached(["fluidity-shell", "screenshot", "region"]) }
        onVpn: { w.close(); Quickshell.execDetached(["bash", "-c", "protonvpn-app || proton-vpn-gtk-app || xdg-open https://account.protonvpn.com"]) }
        onIncognito: { w.close(); Quickshell.execDetached(["zen-browser", "--private-window"]) }
    }
    Process { running: true; command: ["test", "-f", w.home + "/.face"]
              onExited: code => { if (code === 0) view.profile = "file://" + w.home + "/.face" } }
    onOpenChanged: if (open) { w.q = Math.floor(Math.random() * w.quotes.length); view.forceActiveFocus() }
}
