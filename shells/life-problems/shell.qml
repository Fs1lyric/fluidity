// Life Problems: woowak01's "[AwesomeWM] life problems" (r/unixporn q941ym, github ChocolateBread799/dotfiles)
// rebuilt in Quickshell. A cream retro-Mac desktop on teal waves: a rounded ink frame round the screen, the
// outlined menu bar ("Play Edit Video Window Enjoy", window title, date), the clock / vol / cpu / ram / music
// card, the now-playing note and the desktop icons. Windows get cream title bars with two rings and hard
// shadows (theme feel). fluidity-theme starts it (`qs -c life-problems`); Super+` hides the desktop widgets.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool widgets: true
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                margins { top: 38; left: 46; right: 46 }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-lp-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "qs-lp-frame"
                color: "transparent"
                mask: Region {}
                FrameView { anchors.fill: parent }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-lp-desk"
                color: "transparent"
                DeskView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.widgets = !root.widgets } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
