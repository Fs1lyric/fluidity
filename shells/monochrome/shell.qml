// Monochrome: agridyne's first rice (r/unixporn 1tg82cr, github agridyne/dotfiles-dt) rebuilt in Quickshell.
// KDE's two panels as islands (Panel Colorizer), the YoRHa HUD, Thermal Monitor and Kurve on the desktop,
// and the SYSTEM OVERVIEW read-out and scanlines of his "digital gaze" wallpaper, made live.
// fluidity-theme starts it (`qs -c monochrome`) in place of the luminescent bar; `qs -c monochrome ipc call sidebar toggle`
// (Super+`) hides or shows the HUD. Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool hud: true
    Sys { id: live }
    Cava { id: cava; bars: 48; active: root.hud }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-mono-top"
                PanelView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 34; color: "transparent"
                WlrLayershell.namespace: "qs-mono-bottom"
                PanelView { anchors.fill: parent; lower: true; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.hud
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-mono-hud"
                color: "transparent"
                mask: Region {}
                HudView { anchors.fill: parent; sys: live; levels: cava.levels; cursorX: root.cx; cursorY: root.cy; gpuTemp: root.gpu; wallpaper: root.wall }
            }
        }
    }
    // cursor position for the read-out, and the GPU temperature for Thermal Monitor
    Process { id: cur; command: ["hyprctl", "cursorpos"]
              stdout: StdioCollector { onStreamFinished: { const p = text.split(","); if (p.length === 2) { root.cx = +p[0]; root.cy = +p[1] } } } }
    property real cx: 0
    property real cy: 0
    Timer { interval: 250; running: root.hud; repeat: true; onTriggered: cur.running = true }
    property string gpu: "--"
    property string wall: ""
    Process { id: wallQ; command: ["bash", "-c", "awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1"]
              stdout: StdioCollector { onStreamFinished: { const w = text.trim(); if (w && "file://" + w !== root.wall) root.wall = "file://" + w } } }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: wallQ.running = true }
    Process { id: gpuQ; command: ["bash", "-c", "for h in /sys/class/hwmon/hwmon*; do case $(<\"$h/name\") in amdgpu|nouveau|radeon) echo $(( $(<\"$h/temp1_input\") / 1000 )); exit;; esac; done; command -v nvidia-smi >/dev/null && nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader"]
              stdout: StdioCollector { onStreamFinished: if (text.trim()) root.gpu = text.trim() } }
    Timer { interval: 5000; running: root.hud; repeat: true; triggeredOnStart: true; onTriggered: gpuQ.running = true }
    IpcHandler { target: "sidebar"; function toggle(): void { root.hud = !root.hud } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
