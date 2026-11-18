// Neon 80s: Vista1nik's "[i3-gaps] Neon 80s" (r/unixporn c0i8e1, github Vista1nik/i3-neon80s) rebuilt in Quickshell.
// The slim black polybar along the bottom (workspaces on the left; memory, swap, disk, temperature, IP, traffic
// and date on the right, each module in its own neon) and the cava visualizer that sat on his desktop: blue
// bars that turn hot pink as they rise, in a dark glass panel. fluidity-theme starts it (`qs -c neon-80s`);
// Super+` shows or hides the visualizer, Super+F1 the gotop-style stats panel next to it.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool viz: true
    property bool stats: true
    Sys { id: live }
    Cava { id: cava; bars: 36; active: root.viz }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 22; color: "transparent"
                WlrLayershell.namespace: "qs-neon-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.viz || root.stats
                anchors { top: true; left: true; bottom: true }
                margins { top: 60; left: 60; bottom: 30 }
                implicitWidth: 640
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-neon-desk"
                color: "transparent"
                DeskView { anchors.fill: parent; sys: live; levels: cava.levels; showViz: root.viz; showStats: root.stats }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.viz = !root.viz } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.stats = !root.stats } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
