// Manga Light: 1r0sh's "[yabai] gruvbox light" (r/unixporn 1hr894j, github 1r0sh/Mac-rices branch Gruvbox-light)
// rebuilt in Quickshell: the dark sketchybar strip over the cream manga wallpaper, the olive block clock card
// and the cava card on the desktop, and a cmus-shaped control list. Keyboard-only: Super+F1 opens the list
// with the keyboard grabbed (j/k, Enter, h/l, Esc), Super+` hides bar and cards, Super+Esc is the power menu.
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
    Cava { id: cava; bars: 24; active: root.shown }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-manga-bar"
                BarView { anchors.fill: parent; sys: live }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; right: true }
                margins { top: 24; right: 30 }
                implicitWidth: clock.implicitWidth; implicitHeight: clock.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-manga-clock"
                WlrLayershell.layer: WlrLayer.Bottom
                ClockView { id: clock; anchors.fill: parent; now: live.now }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; right: true }
                margins { bottom: 40; right: 40 }
                implicitWidth: viz.implicitWidth; implicitHeight: viz.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-manga-cava"
                WlrLayershell.layer: WlrLayer.Bottom
                CavaView { id: viz; anchors.fill: parent; levels: cava.levels }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open && (Quickshell.screens.length < 2 || per.modelData.name === Hyprland.focusedMonitor?.name)
                implicitWidth: panel.implicitWidth; implicitHeight: panel.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-manga-panel"
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
