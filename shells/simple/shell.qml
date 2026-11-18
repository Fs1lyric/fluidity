// Simple: the "[Hyprland] Simple rice" post (r/unixporn 1wik2gv, no dotfiles) rebuilt in Quickshell: no bar,
// only small black pills floating over a loud lime wallpaper. fluidity-theme starts it (`qs -c simple`);
// Super+` hides or shows the pills. Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 36; color: "transparent"
                WlrLayershell.namespace: "qs-simple-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
