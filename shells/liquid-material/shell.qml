// Liquid Material: the "liquid ass + Material You" post (r/unixporn 1xikmd9, no dotfiles) rebuilt in Quickshell.
// Floating pill bar, the cookie desktop clock, and the control centre (profile, toggles, sliders,
// notifications, calendar / to do / timer). Hyprland blurs behind every qs-lm-* layer (theme feel).
// fluidity-theme starts it (`qs -c liquid-material`); Super+` or Super+F1 toggles the control centre.
// Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool ccOpen: false
    property string wall: ""
    Sys { id: live }
    Cava { id: cava; bars: 28 }
    Process { id: wallQ; command: ["bash", "-c", "awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1"]
              stdout: StdioCollector { onStreamFinished: if (text.trim()) root.wall = "file://" + text.trim() } }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: wallQ.running = true }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-lm-bar"
                BarView { anchors.fill: parent; sys: live; levels: cava.levels; onAct: (w, a) => live.act(w, a); onControlCenter: root.ccOpen = !root.ccOpen }
            }
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-lm-clock"
                color: "transparent"
                mask: Region {}
                ClockView { x: parent.width * 0.43; y: parent.height * 0.17; width: implicitWidth; height: implicitHeight; now: live.now }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.ccOpen
                anchors { top: true; right: true; bottom: true }
                margins { top: 4; right: 6; bottom: 6 }
                implicitWidth: 248
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-lm-cc"
                WlrLayershell.keyboardFocus: root.ccOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                ControlCenterView { width: parent.width; height: Math.min(implicitHeight, parent.height); sys: live; banner: root.wall
                                    onAct: (w, a) => live.act(w, a); focus: true; Keys.onEscapePressed: root.ccOpen = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.ccOpen = !root.ccOpen } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.ccOpen = !root.ccOpen } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
