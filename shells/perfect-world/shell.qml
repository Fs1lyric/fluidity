// Perfect World: elenapan's "Afternoon In A Perfect World" (AwesomeWM amarena, r/unixporn Jul 2020) rebuilt in
// Quickshell for Hyprland. fluidity-theme starts it (`qs -c perfect-world`) in place of the luminescent bar.
//   top: 10 px tag strip    left edge: sidebar    bottom edge: auto-hiding dock
//   `qs -c perfect-world ipc call sidebar toggle`, `... dashboard toggle`, `... exit toggle`
// Notifications, OSD and the theme picker stay in `qs -c fluidity`. Source: ~/claude/luminescent/shells/perfect-world
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool sidebarOpen: false
    property bool dashOpen: false
    property bool exitOpen: false

    Stats { id: sysStats }

    Variants {
        model: Quickshell.screens
        Scope {
            id: perScreen
            required property var modelData
            Tags { screen: perScreen.modelData }
            Dock { screen: perScreen.modelData }
            Sidebar { screen: perScreen.modelData; stats: sysStats; open: root.sidebarOpen
                      onWantOpen: v => root.sidebarOpen = v }
            Dashboard { screen: perScreen.modelData; stats: sysStats; open: root.dashOpen; onClose: root.dashOpen = false }
            ExitScreen { screen: perScreen.modelData; open: root.exitOpen; onClose: root.exitOpen = false }
        }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void { root.sidebarOpen = !root.sidebarOpen }
    }
    IpcHandler {
        target: "dashboard"
        function toggle(): void { root.dashOpen = !root.dashOpen }
    }
    IpcHandler {
        target: "exit"
        function toggle(): void { root.exitOpen = !root.exitOpen }
    }
}
