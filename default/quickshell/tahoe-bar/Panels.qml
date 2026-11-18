pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Which pop-up panel is open ("control", "power", "launcher", "spotlight", "applemenu", ... or ""), and on which screen.
// In Fluidity's mac mode the control centre, power, launcher, wallpaper and theme panels are the Fluidity
// island (qs -c fluidity); the mac-only ones (Apple menu, Spotlight, dialogs) stay here.
Singleton {
    id: panels

    property string open: ""
    property ShellScreen screen: null

    readonly property var island: ({ control: "control", power: "power", launcher: "launcher", wallpaper: "wallpaper", theme: "themes", notifications: "notifications" })
    function toggle(name) {
        if (island[name]) { Quickshell.execDetached(["fluidity-island", island[name]]); return; }
        if (open === name) { open = ""; return; }
        const mon = Hyprland.focusedMonitor?.name;
        screen = Quickshell.screens.find(s => s.name === mon) ?? Quickshell.screens[0];
        open = name;
    }
    function close() { open = "" }

    IpcHandler {
        target: "panel"
        function toggle(name: string): void { panels.toggle(name) }
        function close(): void { panels.close() }
    }
}
