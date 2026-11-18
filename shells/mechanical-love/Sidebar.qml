// The sidebar window: 300 px on the left, over the windows. A 1 px strip on the left edge opens it on hover
// and it hides when the mouse leaves (sidebar_show_on_mouse_edge / sidebar_hide_on_mouse_leave).
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
    signal exitRequested()

    readonly property string dir: Qt.resolvedUrl("shell.qml").toString().replace(/shell\.qml$/, "")
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property PwNode sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [sc.sink] }
    readonly property var bat: UPower.displayDevice
    SystemClock { id: clock; precision: SystemClock.Minutes }

    PanelWindow {
        screen: sc.screen
        anchors { left: true; top: true; bottom: true }
        implicitWidth: 1
        exclusiveZone: 0
        color: "transparent"
        WlrLayershell.namespace: "qs-ml-edge"
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
        WlrLayershell.namespace: "qs-ml-sidebar"
        WlrLayershell.layer: WlrLayer.Overlay

        HoverHandler { id: hover; onHoveredChanged: if (!hovered) sc.wantOpen(false) }

        SidebarView {
            anchors.fill: parent
            iconDir: sc.dir + "icons/"
            weatherDir: sc.dir + "weather/"
            hours: Qt.formatDateTime(clock.date, "HH")
            minutes: Qt.formatDateTime(clock.date, "mm")
            dateText: Qt.formatDateTime(clock.date, "dddd, MMMM d")
            dayOfYear: Math.floor((clock.date - new Date(clock.date.getFullYear(), 0, 0)) / 86400000)
            weatherIcon: sc.stats.weatherIcon
            weatherText: sc.stats.weatherText || "—"
            title: sc.player?.trackTitle ?? "Nothing playing"
            artist: sc.player?.trackArtist ?? ""
            volume: sc.sink?.audio?.volume ?? 0
            muted: sc.sink?.audio?.muted ?? false
            cpu: sc.stats.cpu
            ram: sc.stats.ram
            temp: sc.stats.temp
            hasBattery: sc.bat?.isLaptopBattery ?? false
            battery: sc.bat?.percentage ?? 0
            charging: sc.bat?.state === UPowerDeviceState.Charging
            diskFree: sc.stats.diskFree

            onPrev: sc.player?.previous()
            onToggle: sc.player?.togglePlaying()
            onNext: sc.player?.next()
            onMuteClicked: if (sc.sink?.audio) sc.sink.audio.muted = !sc.sink.audio.muted
            onVolumeStep: d => { if (sc.sink?.audio) sc.sink.audio.volume = Math.max(0, Math.min(1, sc.sink.audio.volume + d * 0.05)) }
            onSearch: { sc.wantOpen(false); Quickshell.execDetached(["bash", "-c", "pkill fuzzel || fuzzel"]) }
            onExit: sc.exitRequested()
        }
    }
}
