pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// The full-screen theme picker (Super+Ctrl+Shift+Space): rows from `fluidity-theme rows`.
Singleton {
    id: tp
    property bool shown: false
    property string rows: ""
    property string current: ""
    property ShellScreen screen: Quickshell.screens[0]

    function toggle() {
        if (shown) { shown = false; return; }
        const mon = Hyprland.focusedMonitor?.name;
        screen = Quickshell.screens.find(s => s.name === mon) ?? Quickshell.screens[0];
        rowsProc.running = true; curProc.running = true;
        shown = true;
    }
    function apply(name) { shown = false; if (name && name !== current) Quickshell.execDetached(["fluidity-theme", "set", name]); }

    Process { id: rowsProc; command: ["fluidity-theme", "rows"]; stdout: StdioCollector { onStreamFinished: tp.rows = String(text || "").trim() } }
    Process { id: curProc; command: ["fluidity-theme", "current"]; stdout: StdioCollector { onStreamFinished: tp.current = String(text || "").trim() } }
    IpcHandler { target: "themepicker"; function toggle(): void { tp.toggle() } }
}
