// His eww sidebar boxes on the left, toggled (Super+` or the clock pill). Sits over windows.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "Pal.js" as P
import "Power.js" as Pw

PanelWindow {
    id: w
    required property var stats
    property bool open: false
    visible: open
    anchors { left: true; top: true }
    margins.top: -36
    implicitWidth: 320; implicitHeight: 760
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.namespace: "qs-ni-sidebar"
    WlrLayershell.layer: WlrLayer.Overlay

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property PwNode sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [w.sink] }
    readonly property var bat: UPower.displayDevice
    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property bool night: { const h = clock.date.getHours(); return h < 6 || h >= 19 }
    readonly property var wx: P.weather(w.stats.weatherCond, night)

    SidebarView {
        anchors.fill: parent
        day: Qt.formatDateTime(clock.date, "d")
        month: Qt.formatDateTime(clock.date, "MMM")
        hours: Qt.formatDateTime(clock.date, "HH")
        minutes: Qt.formatDateTime(clock.date, "mm")
        weekday: Qt.formatDateTime(clock.date, "dddd")
        weatherGlyph: w.wx[0]
        temp: w.stats.weatherTemp ? w.stats.weatherTemp + "°C" : "—"
        cond: w.stats.weatherCond || "—"
        art: w.player?.trackArtUrl ?? ""
        title: w.player?.trackTitle ?? ""
        playing: w.player?.isPlaying ?? false
        volume: w.sink?.audio?.muted ? 0 : (w.sink?.audio?.volume ?? 0)
        brightness: w.stats.brightness
        ram: w.stats.ram
        battery: w.bat?.isLaptopBattery ? w.bat.percentage : 1
        onPrev: w.player?.previous()
        onToggle: w.player?.togglePlaying()
        onNext: w.player?.next()
        onSearch: { w.open = false; Quickshell.execDetached(["bash", "-c", "pkill fuzzel || fuzzel"]) }
        onPower: a => Quickshell.execDetached(Pw.commands[a])
        onVolumeSet: v => { if (w.sink?.audio) w.sink.audio.volume = v }
        onBrightnessSet: v => Quickshell.execDetached(["brightnessctl", "set", Math.round(v * 100) + "%"])
    }
}
