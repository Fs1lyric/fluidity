// Red Skull: maotseantonio's "[Hyprland] NiOS" (r/unixporn 1i79aqc; his github is gone, rebuilt from the shots)
// in Quickshell: Keyitdev's sddm-astronaut "post-apocalyptic hacker" wallpaper and clock on the desktop, his
// floating NiOS bar in that palette, and the login form as a session panel. Keyboard-only: Super+F1 opens the
// panel with the keyboard grabbed (arrows/hjkl, Enter, Esc), Super+` hides bar and clock, Super+Esc power menu.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    FontLoader { source: "FragileBombersAttack.otf" }
    FontLoader { source: "OpenSans-SemiBold.ttf" }
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
                implicitHeight: 40; color: "transparent"
                WlrLayershell.namespace: "qs-skull-bar"
                BarView { anchors.fill: parent; sys: live }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; right: true }
                margins { top: Math.round(per.modelData.height * 0.17); right: Math.round(per.modelData.width * 0.13) }
                implicitWidth: clock.implicitWidth; implicitHeight: clock.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-skull-clock"
                WlrLayershell.layer: WlrLayer.Bottom
                ClockView { id: clock; now: live.now }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-skull-panel"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                PanelView { id: panel; anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a); onClose: root.open = false }
                onVisibleChanged: if (visible) panel.forceActiveFocus()
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
