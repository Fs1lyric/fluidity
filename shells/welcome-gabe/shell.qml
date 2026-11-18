// Welcome Gabe: Gbox4's "[bspwm] welcome back" (r/unixporn souv1t, github Gbox4/dotfiles, colors cyber3) rebuilt
// in Quickshell: the two Fira Code polybars (roman-numeral desktops, purple powerline segments), the
// "WELCOME BACK <you>" lolcat splash that opens like his startup script, and an ncmpcpp-shaped control window.
// Keyboard-only: Super+F1 opens the control window with the keyboard grabbed (j/k, Enter, h/l, Esc), Super+F2
// replays the splash, Super+` hides the bars, Super+Esc is the power menu. fluidity-theme starts it.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    property bool welcome: true
    property real grow: 0
    property real brightness: -1
    FontLoader { source: "FiraCode-Regular.ttf" }
    FontLoader { source: "FiraCode-Bold.ttf" }
    Sys { id: live }
    Cava { id: cava; bars: 48; active: root.open }
    Process { id: readBright; running: true; command: ["brightnessctl", "-m", "-c", "backlight"]
              stdout: StdioCollector { onStreamFinished: { const f = text.trim().split(","); if (f.length > 3) root.brightness = parseInt(f[3]) / 100 } } }
    // his w_popup: grow the window open, hold the greeting, close
    SequentialAnimation {
        id: splashAnim
        running: true
        ScriptAction { script: { root.grow = 0; root.welcome = true } }
        NumberAnimation { target: root; property: "grow"; from: 0; to: 1; duration: 700; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 2200 }
        NumberAnimation { target: root; property: "grow"; to: 0; duration: 350; easing.type: Easing.InCubic }
        ScriptAction { script: root.welcome = false }
    }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 22; color: "transparent"
                WlrLayershell.namespace: "qs-gabe-top"
                TopBar { anchors.fill: parent; sys: live }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 22; color: "transparent"
                WlrLayershell.namespace: "qs-gabe-bottom"
                BottomBar { anchors.fill: parent; sys: live; brightness: root.brightness }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.welcome
                implicitWidth: 1300; implicitHeight: 700
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-gabe-splash"
                WlrLayershell.layer: WlrLayer.Overlay
                Splash { anchors.centerIn: parent; grow: root.grow; name: (live.user || "friend").toUpperCase() }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-gabe-panel"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                PanelView { id: panel; anchors.fill: parent; sys: live; levels: cava.levels
                            onAct: (w, a) => live.act(w, a); onClose: root.open = false; onSplash: splashAnim.restart() }
                onVisibleChanged: if (visible) panel.forceActiveFocus()
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "splash"; function play(): void { splashAnim.restart() } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
