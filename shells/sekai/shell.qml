// Sekai: Single-Flamingo-8194's "Project Sekai Inspired Quickshell" (r/unixporn 1x37y28, SekaiPop by Blapples)
// rebuilt in Quickshell: chunky outlined pills along the top, the To-Do card on the left, the big lilac / sky
// clock on the right and the dark teal dock with the now-playing card at the bottom.
// fluidity-theme starts it (`qs -c sekai`); Super+` hides or shows the desktop widgets (To-Do + clock).
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool widgets: true
    FontLoader { source: "MPLUSRounded1c-Black.ttf" }
    FontLoader { source: "MPLUSRounded1c-ExtraBold.ttf" }
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-sekai-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                anchors { bottom: true }
                margins { bottom: 8 }
                implicitWidth: dock.implicitWidth; implicitHeight: 54; color: "transparent"
                WlrLayershell.namespace: "qs-sekai-dock"
                DockView { id: dock; anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { left: true; top: true }
                margins { left: 14; top: 120 }
                implicitWidth: 300; implicitHeight: 420
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-sekai-todo"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
                color: "transparent"
                TodoView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { right: true; top: true }
                margins { right: 40; top: per.modelData.height * 0.4 }
                implicitWidth: clock.implicitWidth; implicitHeight: 140
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-sekai-clock"
                color: "transparent"
                mask: Region {}
                ClockView { id: clock; now: live.now }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.widgets = !root.widgets } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
