// Forest: nuxshed's "[AwesomeWM] forest" (r/unixporn rs0wm4, github nuxshed/dotfiles, themes/forest at
// 6bcdd8a) rebuilt in Quickshell: gruvbox-material on the misty forest stairs, the floating bottom bar and his
// control centre. Keyboard-only: Super+F1 opens the control centre with the keyboard grabbed, Super+` hides
// the bar, Super+Esc is the power menu. fluidity-theme starts it (`qs -c forest`).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    property real brightness: -1
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Light.ttf" }
    Sys { id: live }
    // brightnessctl -m: "intel_backlight,backlight,412,43%,960"; no backlight leaves -1 and hides the slider
    Process { id: readBright; command: ["brightnessctl", "-m", "-c", "backlight"]
              stdout: StdioCollector { onStreamFinished: { const f = text.trim().split(","); if (f.length > 3) root.brightness = parseInt(f[3]) / 100 } } }
    onOpenChanged: if (open) readBright.running = true
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 52; color: "transparent"
                WlrLayershell.namespace: "qs-forest-bar"
                BarView { anchors.fill: parent; sys: live; panelOpen: root.open }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                anchors { bottom: true; right: true }
                margins { bottom: 50; right: 10 }
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-forest-panel"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                PanelView { id: panel; anchors.fill: parent; sys: live; brightness: root.brightness
                            onAct: (w, a) => { live.act(w, a); if (w === "brightness") root.brightness = a }
                            onClose: root.open = false }
                onVisibleChanged: if (visible) panel.forceActiveFocus()
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
