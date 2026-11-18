// FILESYSTEM (your home folder, double-click to go in, ~ to go up) and the on-screen keyboard (types with wtype).
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: w
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 335
    exclusiveZone: 335
    color: "transparent"
    WlrLayershell.namespace: "qs-edex-bottom"
    WlrLayershell.layer: WlrLayer.Bottom
    property string cwd: Quickshell.env("HOME")
    property var entries: []
    property string mount: "/"
    property real used: 0
    Process { id: ls; command: ["bash", "-c", "cd \"$1\" && ls -1Ap --group-directories-first | head -80", "_", w.cwd]
              stdout: StdioCollector { onStreamFinished: w.entries = text.split("\n").filter(x => x) } }
    Process { id: df; command: ["bash", "-c", "df --output=target,pcent \"$1\" | tail -1", "_", w.cwd]
              stdout: StdioCollector { onStreamFinished: { const p = text.trim().split(/\s+/); w.mount = p[0] || "/"; w.used = (+(p[1] || "0").replace("%", "")) / 100 } } }
    onCwdChanged: { ls.running = true; df.running = true }
    Component.onCompleted: { ls.running = true; df.running = true }
    readonly property var special: ({ "ESC": "Escape", "BACK": "BackSpace", "TAB": "Tab", "ENTER": "Return", "": "space",
                                      "▲": "Up", "▼": "Down", "◀": "Left", "▶": "Right" })
    BottomView {
        anchors.fill: parent
        cwd: w.cwd
        entries: w.entries
        mount: w.mount
        used: w.used
        onUp: w.cwd = w.cwd.replace(/\/[^\/]+$/, "") || "/"
        onOpen: n => { if (n.endsWith("/")) w.cwd = (w.cwd === "/" ? "" : w.cwd) + "/" + n.slice(0, -1);
                       else Quickshell.execDetached(["xdg-open", w.cwd + "/" + n]) }
        onKey: k => { if (["CAPS", "CTRL", "FN", "ALT GR"].indexOf(k) >= 0) return;
                      Quickshell.execDetached(w.special[k] !== undefined ? ["wtype", "-k", w.special[k]] : ["wtype", k]) }
    }
}
