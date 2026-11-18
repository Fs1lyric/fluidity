// Mechanical Love: elenapan's AwesomeWM setup (r/unixporn, Dec 2018) rebuilt in Quickshell for Hyprland.
// fluidity-theme starts it (`qs -c mechanical-love`) in place of the luminescent bar when the theme is picked.
//   sidebar: left edge hover (hides when the mouse leaves) or `qs -c mechanical-love ipc call sidebar toggle`
//   exit screen: `qs -c mechanical-love ipc call exit toggle` (keys p r s e l, Esc closes)
// Notifications, OSD and the theme picker stay in `qs -c fluidity`. Source: ~/claude/luminescent/shells/mechanical-love
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool sidebarOpen: false
    property bool exitOpen: false

    Stats { id: sysStats }

    Variants {
        model: Quickshell.screens
        Scope {
            id: perScreen
            required property var modelData
            Tagbar { screen: perScreen.modelData; onMenu: root.sidebarOpen = !root.sidebarOpen }
            Sidebar { screen: perScreen.modelData; stats: sysStats; open: root.sidebarOpen
                      onWantOpen: v => root.sidebarOpen = v
                      onExitRequested: { root.sidebarOpen = false; root.exitOpen = true } }
            ExitScreen { screen: perScreen.modelData; open: root.exitOpen; onClose: root.exitOpen = false }
        }
    }

    IpcHandler {
        target: "sidebar"
        function toggle(): void { root.sidebarOpen = !root.sidebarOpen }
        function show(): void { root.sidebarOpen = true }
        function hide(): void { root.sidebarOpen = false }
    }
    IpcHandler {
        target: "exit"
        function toggle(): void { root.exitOpen = !root.exitOpen }
    }
}
