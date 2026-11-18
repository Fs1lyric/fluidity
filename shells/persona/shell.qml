// Persona: DjentGod123's "PersonaShell v2" (r/unixporn 1u86dr2, github Yujonpradhananga/Persona-Quickshell)
// rebuilt in Quickshell. The giant see-through date ("15 06") painted over the train windows, the P3R clock card
// in the top right (time, weekday, time of day, battery, moon phase) and the Persona 3 pause menu.
// fluidity-theme starts it (`qs -c persona`); Super+` hides the clock, Super+F1 opens the pause menu.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool menu: false
    FontLoader { source: "DMSerifDisplay.ttf" }
    FontLoader { source: "Anton.ttf" }
    Sys { id: live }
    property bool depth: false
    Process { id: wallQ; command: ["bash", "-c", "awww query 2>/dev/null | grep -q persona-post"]; onExited: code => root.depth = code === 0 }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: wallQ.running = true }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {   // desktop layer: the big date + the clock card, clicks go through
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-persona-desk"
                color: "transparent"
                mask: Region {}
                DeskView { anchors.fill: parent; sys: live; depth: root.depth }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.menu
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "qs-persona-menu"
                WlrLayershell.keyboardFocus: root.menu ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                color: "transparent"
                MenuView { anchors.fill: parent; sys: live; focus: true
                           onAct: (w, a) => { root.menu = false; live.act(w, a) }; onClose: root.menu = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.menu = !root.menu } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
