// Pixel Clock: Bahaaio's "[i3] debian" (r/unixporn 1oyspun, github Bahaaio/dotfiles at f4324b7, polybar + kanso
// zen) rebuilt in Quickshell: the flat polybar strip, the big tty-clock block clock on the desktop and a
// btop-style dashboard. Keyboard-only: Super+F1 opens the dashboard with the keyboard grabbed (arrows/hjkl,
// Enter, Esc), Super+` hides the bar and clock, Super+Esc is the power menu. fluidity-theme starts it.
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
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
    Sys { id: live }
    // brightnessctl -m: "intel_backlight,backlight,412,43%,960"; no backlight leaves -1 and hides it
    Process { id: readBright; running: true; command: ["brightnessctl", "-m", "-c", "backlight"]
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
                anchors { top: true; left: true; right: true }
                implicitHeight: 28; color: "transparent"
                WlrLayershell.namespace: "qs-pixel-bar"
                BarView { anchors.fill: parent; sys: live; brightness: root.brightness }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; right: true }
                margins { top: 70; right: 50 }
                implicitWidth: clock.implicitWidth; implicitHeight: clock.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-pixel-clock"
                WlrLayershell.layer: WlrLayer.Bottom
                ClockView { id: clock; anchors.fill: parent; now: live.now }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-pixel-panel"
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
