// eDEX Tron: eDEX-UI (GitSquared, r/unixporn's #1 post of all time) rebuilt as a Quickshell desktop for Hyprland.
// Left: the SYSTEM and NETWORK module columns. Bottom: FILESYSTEM and the on-screen keyboard. Windows live in the
// TERMINAL / MAIN SHELL frame. `qs -c edex ipc call sidebar toggle` (Super+`) hides or shows the bottom row.
// Notifications, OSD and the theme picker stay in `qs -c fluidity`. Source: ~/claude/luminescent/shells/edex
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool bottomShown: true
    // eDEX's fonts ship with the shell
    FontLoader { source: "united_sans_medium.ttf" }
    FontLoader { source: "united_sans_light.otf" }
    FontLoader { source: "fira_mono.ttf" }
    Stats { id: sysStats }
    Variants {
        model: Quickshell.screens
        Scope {
            id: perScreen
            required property var modelData
            Backdrop { screen: perScreen.modelData; bottomShown: root.bottomShown }
            Columns { screen: perScreen.modelData; stats: sysStats; bottomShown: root.bottomShown }
            Bottom { screen: perScreen.modelData; visible: root.bottomShown }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.bottomShown = !root.bottomShown } }
    IpcHandler { target: "exit"; function toggle(): void { Quickshell.execDetached(["qs", "-c", "fluidity", "ipc", "call", "panel", "toggle", "power"]) } }
}
