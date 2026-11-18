// The desktop layer of agridyne's rice, under the windows:
//   left: the "SYSTEM OVERVIEW" read-out from his video wallpaper, made live (time, date, process, volume, media,
//         other time zones, resolution, cursor); left edge: Kurve audio visualizer
//   right: YoRHa HUD (bunker link, unit, loads) and Thermal Monitor (CPU / GPU temperature)
//   over everything: the fine vertical scanlines of the wallpaper
import QtQuick
import QtQuick.Effects

Item {
    id: h
    property var sys
    property var levels: []          // Kurve: 0..1 per bar (cava)
    property real cursorX: 0
    property real cursorY: 0
    property string gpuTemp: "--"
    property string wallpaper: ""    // the current wallpaper, painted in black and white under everything
    readonly property color fg: "#e6e6e6"
    readonly property color dim: "#9a9a9a"
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property date now: sys?.now ?? new Date()
    function pad(s, n) { s = String(s); while (s.length < n) s += " "; return s }
    function bar(v, n) { const k = Math.round(Math.max(0, Math.min(1, v)) * n); return "[" + "|".repeat(k) + ".".repeat(n - k) + "]" }
    function zone(offsetH) { const d = new Date(h.now.getTime() + (offsetH * 60 + h.now.getTimezoneOffset()) * 60000); return Qt.formatTime(d, "HH  mm  ss") }
    function stamp(d) { return Qt.formatTime(d, "HH  mm  ss") }
    function dur(s) { s = Math.max(0, Math.round(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }

    component Hud: Text { color: h.fg; font.family: h.font; font.pixelSize: 13; font.letterSpacing: 1.5; font.capitalization: Font.AllUppercase; textFormat: Text.PlainText }

    Image { id: wall; anchors.fill: parent; source: h.wallpaper; fillMode: Image.PreserveAspectCrop; visible: false; asynchronous: true }
    MultiEffect { anchors.fill: parent; source: wall; visible: h.wallpaper !== ""; saturation: -1; contrast: 0.15 }

    // SYSTEM OVERVIEW (left)
    Column {
        x: parent.width * 0.065; y: parent.height * 0.10; spacing: 4
        Hud { text: "System overview"; font.pixelSize: 15 }
        Hud { text: "wallpaper loading   ~~~   terminal calibrated  |  " + (h.sys?.host ?? ""); color: h.dim; font.pixelSize: 10 }
        Item { width: 1; height: 26 }
        Hud { text: h.pad("time", 10) + h.stamp(h.now) }
        Hud { text: h.pad("date", 10) + Qt.formatDate(h.now, "dd  MM  yy") }
        Item { width: 1; height: 16 }
        Hud { text: h.pad("day", 10) + "[" + Qt.formatDate(h.now, "ddd") + "]" }
        Hud { text: h.pad("process", 10) + "[" + Math.round((h.sys?.cpu ?? 0) * 100) + "%]  " + h.bar(h.sys?.cpu ?? 0, 20) }
        Item { width: 1; height: 24 }
        Hud { text: h.pad("volume", 10) + (h.sys?.muted ? "[muted]" : "[" + Math.round((h.sys?.volume ?? 0) * 100) + "%]") }
        Hud { text: h.pad("status", 10) + (h.sys?.hasPlayer ? (h.sys.playing ? "playing" : "paused") : "no sound detected") }
        Hud { text: h.pad("title", 10) + (h.sys?.track ?? "") }
        Item { width: 1; height: 16 }
        Hud { text: h.pad("artist", 10) + (h.sys?.artist ?? "") }
        Item { width: 1; height: 16 }
        Hud { text: h.pad("duration", 10) + (h.sys?.hasPlayer ? h.dur(h.sys.position) + " / " + h.dur(h.sys.length) : "") }
        Hud { text: h.pad("type", 10) + (h.sys?.hasPlayer ? "audio" : "") }
        Item { width: 1; height: 34 }
        Hud { text: h.pad("time-2", 10) + "[tok] " + h.zone(9) }
        Hud { text: h.pad("status", 10) + "today" }
        Item { width: 1; height: 8 }
        Hud { text: h.pad("time-3", 10) + "[nyc] " + h.zone(-5) }
        Hud { text: h.pad("status", 10) + "yesterday" }
        Item { width: 1; height: 34 }
        Hud { text: h.pad("resolution", 12) + h.width + "  " + h.height }
        Hud { text: h.pad("cursor-x", 12) + h.cursorX.toFixed(2) }
        Hud { text: h.pad("cursor-y", 12) + h.cursorY.toFixed(2) }
    }

    // [NEXT YEAR] count-up (top right of the wallpaper)
    Column {
        anchors { right: parent.right; rightMargin: parent.width * 0.08 }
        y: parent.height * 0.20
        Hud { anchors.right: parent.right; text: "[next year]   count-up" }
        Hud { anchors.right: parent.right; color: h.dim
              text: Math.floor((h.now - new Date(h.now.getFullYear(), 0, 1)) / 86400000) + " days passed" }
    }

    // YoRHa HUD + Thermal Monitor (right)
    Column {
        anchors { right: parent.right; rightMargin: parent.width * 0.04 }
        y: parent.height * 0.42; spacing: 3
        Row { spacing: 40
            Column { Hud { text: "bunker_link : " + (h.sys?.online ? "established [ | ]" : "lost [   ]"); font.pixelSize: 11 }
                     Hud { text: "signal_str  : " + ((h.sys?.wired ? 1 : h.sys?.wifiStrength ?? 0) * 100).toFixed(1) + "%"; font.pixelSize: 11 } }
            Column { Hud { text: "unit_id  : 2b_model_s"; font.pixelSize: 11 }
                     Hud { text: "pod_prog : r010: laser"; font.pixelSize: 11 }
                     Hud { text: "status   : " + (h.sys?.cpu > 0.6 ? "combat" : "analysing"); font.pixelSize: 11; color: h.dim } }
        }
        Item { width: 1; height: 14 }
        Row { spacing: 40
            Column { Hud { text: "cpu_load : " + h.bar(h.sys?.cpu ?? 0, 12) + " " + Math.round((h.sys?.cpu ?? 0) * 100); font.pixelSize: 11 }
                     Hud { text: "ram_use  : " + h.bar(h.sys?.ram ?? 0, 12) + " " + Math.round((h.sys?.ram ?? 0) * 100); font.pixelSize: 11 } }
            Column { Hud { text: "disk_use : " + h.bar(h.sys?.diskUsed ?? 0, 10) + " " + Math.round((h.sys?.diskUsed ?? 0) * 100); font.pixelSize: 11 }
                     Hud { text: "net_rx   : " + Math.round((h.sys?.netDown ?? 0) / 1024) + " kib/s"; font.pixelSize: 11 } }
        }
        Item { width: 1; height: 10 }
        Hud { text: "> exploring wide-web matrix...      black_box_sync : " + Math.round(100 - (h.sys?.ram ?? 0) * 10) + ".0%"; font.pixelSize: 10; color: h.dim }
        Hud { text: "> uptime " + (h.sys?.uptime ?? "") + "      logical_virus : clean"; font.pixelSize: 10; color: h.dim }
        Item { width: 1; height: 10 }
        Hud { anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 12
              text: (h.sys?.temp ?? 0) > 85 ? "[ thermal warning ]" : "[ all systems nominal ]" }
        Item { width: 1; height: 10 }
        Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 40
            Column { Hud { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(h.sys?.temp ?? 0) + " °C"; font.pixelSize: 12 }
                     Text { anchors.horizontalCenter: parent.horizontalCenter; text: "CPU Temperature"; color: h.dim; font.family: h.font; font.pixelSize: 9 } }
            Column { Hud { anchors.horizontalCenter: parent.horizontalCenter; text: h.gpuTemp + " °C"; font.pixelSize: 12 }
                     Text { anchors.horizontalCenter: parent.horizontalCenter; text: "GPU Temperature"; color: h.dim; font.family: h.font; font.pixelSize: 9 } } }
    }

    // Kurve: vertical bars growing out of the left edge
    Column {
        x: 0; anchors.verticalCenter: parent.verticalCenter; spacing: 3
        Repeater {
            model: h.levels.length ? h.levels : Array(48).fill(0)
            Rectangle { required property var modelData; height: 6; width: 3 + modelData * h.width * 0.05; color: Qt.rgba(1, 1, 1, 0.55)
                        Behavior on width { NumberAnimation { duration: 60 } } }
        }
    }

    // fine vertical scanlines over the desktop
    Row {
        anchors.fill: parent; spacing: 3
        Repeater { model: Math.ceil(h.width / 4); Rectangle { width: 1; height: h.height; color: Qt.rgba(0, 0, 0, 0.22) } }
    }
}
