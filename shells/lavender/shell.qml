// Lavender: the "[Hyprland] HyprPanel lavender" rice (r/unixporn 1k4sv22, no dotfiles linked, rebuilt from the
// screenshots): the pale lavender HyprPanel bar with deeper pills over the sleeping bunny, and his Spotify poster card
// grown into a keyboard-driven control panel. Keyboard-only: Super+F1 opens the panel with the keyboard grabbed,
// Super+` hides the bar, Super+Esc is the power menu. fluidity-theme starts it (`qs -c lavender`).
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
                implicitHeight: 40; color: "transparent"
                WlrLayershell.namespace: "qs-lavender-bar"
                BarView { anchors.fill: parent; sys: live }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                anchors { top: true; right: true }
                margins { top: 46; right: 8 }
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-lavender-panel"
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
