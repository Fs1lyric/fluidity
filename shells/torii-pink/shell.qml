// Torii Pink: gitKhym's "[Hyprland] AGS" (r/unixporn 1r9h3qb, github gitKhym/dotfiles, ags/yuu) rebuilt in
// Quickshell: dark islands in Lexend Deca with the #F6A0CA accent and the notch island over the torii gate;
// Super+F1 drops the island down into a keyboard-driven panel (arrows/hjkl, Enter, Esc),
// Super+` hides the bar, Super+Esc is the power menu. fluidity-theme starts it (`qs -c torii-pink`).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    FontLoader { source: "LexendDeca-Regular.ttf" }
    FontLoader { source: "LexendDeca-Medium.ttf" }
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
                implicitHeight: 44; color: "transparent"
                WlrLayershell.namespace: "qs-torii-bar"
                BarView { anchors.fill: parent; sys: live; expanded: root.open }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                anchors { top: true }
                margins { top: 0 }
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-torii-panel"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                PanelView { id: panel; anchors.fill: parent; sys: live
                            onAct: (w, a) => live.act(w, a)
                            onClose: root.open = false }
                onVisibleChanged: if (visible) panel.forceActiveFocus()
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
