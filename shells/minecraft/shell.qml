// Minecraft: hooss_only's "[hyprland] MINECRAFT" (r/unixporn 1n9ubeg, github hooss-only/dotfiles-minecraft-style)
// rebuilt in Quickshell: the survival HUD at the bottom centre is the status bar (hearts = free memory, hunger =
// battery, items = workspaces, XP bar = CPU) and the date sits bottom-left in the Minecraft font. Pixel art is
// drawn here, no game textures. Windows get the grey inventory-style frame (theme feel).
// fluidity-theme starts it (`qs -c minecraft`); Super+` hides or shows the HUD.
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
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 96; color: "transparent"
                WlrLayershell.namespace: "qs-mc-hud"
                HotbarView { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                             width: implicitWidth; height: implicitHeight; sys: live; onAct: (w, a) => live.act(w, a) }
                ClockView { anchors.left: parent.left; anchors.bottom: parent.bottom; now: live.now
                            MouseArea { anchors.fill: parent; onClicked: live.act("launcher", null) } }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
