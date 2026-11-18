// The sidebar window: 300 px on the left over the windows, opened by the left edge, hidden on mouse leave.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Scope {
    id: sc
    required property var screen
    required property var stats
    property bool open: false
    signal wantOpen(bool v)

    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property PwNode sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [sc.sink] }
    readonly property var bat: UPower.displayDevice
    readonly property var weatherGlyph: ({ sun: "sun", star: "moon", dcloud: "partly", ncloud: "partly", cloud: "cloud",
                                           mist: "fog", rain: "rain", snow: "snow", storm: "storm", whatever: "cloud" })
    SystemClock { id: clock; precision: SystemClock.Minutes }

    PanelWindow {
        screen: sc.screen
        anchors { left: true; top: true; bottom: true }
        implicitWidth: 1
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "qs-pw-edge"
        WlrLayershell.layer: WlrLayer.Overlay
        MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: sc.wantOpen(true) }
    }

    PanelWindow {
        screen: sc.screen
        visible: sc.open
        anchors { left: true; top: true; bottom: true }
        implicitWidth: 300
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "qs-pw-sidebar"
        WlrLayershell.layer: WlrLayer.Overlay
        HoverHandler { onHoveredChanged: if (!hovered) sc.wantOpen(false) }

        SidebarView {
            anchors.fill: parent
            hours: Qt.formatDateTime(clock.date, "HH")
            minutes: Qt.formatDateTime(clock.date, "mm")
            weekday: (clock.date.getDay() + 6) % 7
            battery: sc.bat?.isLaptopBattery ? sc.bat.percentage : 1
            charging: sc.bat?.isLaptopBattery ? sc.bat.state === UPowerDeviceState.Charging : true
            weatherText: sc.stats.weatherCond || "—"
            weatherTemp: sc.stats.weatherTemp
            weatherGlyph: sc.weatherGlyph[sc.stats.weatherIcon] ?? "cloud"
            title: sc.player?.trackTitle ?? "Nothing playing"
            artist: sc.player?.trackArtist ?? ""
            volume: sc.sink?.audio?.volume ?? 0
            muted: sc.sink?.audio?.muted ?? false
            cpu: sc.stats.cpu
            temp: sc.stats.temp
            ram: sc.stats.ram
            brightness: sc.stats.brightness
            onPrev: sc.player?.previous()
            onToggle: sc.player?.togglePlaying()
            onNext: sc.player?.next()
            onMuteClicked: if (sc.sink?.audio) sc.sink.audio.muted = !sc.sink.audio.muted
            onVolumeStep: d => { if (sc.sink?.audio) sc.sink.audio.volume = Math.max(0, Math.min(1, sc.sink.audio.volume + d * 0.05)) }
            onBrightnessStep: d => Quickshell.execDetached(["brightnessctl", "set", d > 0 ? "+5%" : "5%-"])
            onSearch: { sc.wantOpen(false); Quickshell.execDetached(["bash", "-c", "pkill fuzzel || fuzzel"]) }
            onBatteryClicked: Quickshell.execDetached(["qs", "-c", "fluidity", "ipc", "call", "panel", "toggle", "control"])
        }
    }
}
