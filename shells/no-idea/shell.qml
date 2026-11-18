// No Idea: Axarva's xmonad + eww + tint2 setup (r/unixporn, Dec 2020, "you have no idea what's possible")
// rebuilt in Quickshell for Hyprland. fluidity-theme starts it (`qs -c no-idea`) in place of the luminescent bar.
//   top: his tint2 pills    bottom: his candy-icons launcher    sidebar + dashboard: his eww windows
//   `qs -c no-idea ipc call sidebar toggle` (Super+`), `... dashboard toggle` (Super+F1, Super+Esc)
// Notifications, OSD and the theme picker stay in `qs -c fluidity`. Source: ~/claude/luminescent/shells/no-idea
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool sidebarOpen: false
    property bool dashOpen: false
    Stats { id: sysStats }
    Variants {
        model: Quickshell.screens
        Scope {
            id: perScreen
            required property var modelData
            Top { screen: perScreen.modelData; onClockClicked: root.sidebarOpen = !root.sidebarOpen }
            Dock { screen: perScreen.modelData }
            Sidebar { screen: perScreen.modelData; stats: sysStats; open: root.sidebarOpen }
            Dashboard { screen: perScreen.modelData; stats: sysStats; open: root.dashOpen; onClose: root.dashOpen = false }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.sidebarOpen = !root.sidebarOpen } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.dashOpen = !root.dashOpen } }
    // his power options live on the dashboard
    IpcHandler { target: "exit"; function toggle(): void { root.dashOpen = !root.dashOpen } }
}
