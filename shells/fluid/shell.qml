// Fluid: ilyamiro's "[Hyprland] fluid" (r/unixporn 1s84jik, github ilyamiro/nixos-configuration, now
// Serpantinum) rebuilt in Quickshell: his top bar of near-black pills with the lime matugen accent, in
// JetBrains Mono, and a control panel after his player and quick-actions cards.
// Keyboard-only: Super+F1 opens the panel with the keyboard grabbed (arrows/hjkl, Enter, Esc), Super+` hides
// the bar, Super+Esc is the power menu. fluidity-theme starts it (`qs -c fluid`).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
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
                WlrLayershell.namespace: "qs-fluid-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                anchors { top: true; right: true }
                margins { top: 6; right: 8 }
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-fluid-panel"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                PanelView { id: panel; anchors.fill: parent; sys: live
                            onAct: (w, a) => live.act(w, a); onClose: root.open = false
                            Component.onCompleted: forceActiveFocus() }
                onVisibleChanged: if (visible) panel.forceActiveFocus()
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
