// Ax-Shell: Axenide's "Are we Fabricating yet?" (r/unixporn 1hw6ur3, Fabric, github Axenide/Ax-Shell) in Quickshell.
// Floating near-black pills on the red Gundam wallpaper: launcher button + workspace dots (the focused one
// stretches into a pink pill) on the left, the notch in the middle (user@host, or the focused window), and
// the tray-ish buttons, clock and power on the right. The notch opens into the dashboard (clock, calendar,
// player, toggles, stats). fluidity-theme starts it (`qs -c ax-shell`); Super+` or Super+F1 opens the notch.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool open: false
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 40; color: "transparent"
                WlrLayershell.namespace: "qs-ax-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a); onNotch: root.open = !root.open }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open
                anchors { top: true }
                margins { top: 4 }
                implicitWidth: 760; implicitHeight: 300
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-ax-notch"
                WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                DashView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a); onClose: root.open = false
                           focus: true; Keys.onEscapePressed: root.open = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
