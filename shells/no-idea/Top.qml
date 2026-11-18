// The tint2 pills along the top (reserve 44 px).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.UPower
import Quickshell.Wayland

PanelWindow {
    id: bar
    signal clockClicked()
    anchors { top: true; left: true; right: true }
    implicitHeight: 44
    exclusiveZone: 36
    color: "transparent"
    WlrLayershell.namespace: "qs-ni-top"

    SystemClock { id: clock; precision: SystemClock.Minutes }
    readonly property var tags: {
        const focused = Hyprland.focusedWorkspace?.id ?? -1, wins = Hyprland.toplevels.values, byId = {};
        for (const w of Hyprland.workspaces.values) byId[w.id] = w;
        const out = [];
        for (let i = 1; i <= 9; i++)
            out.push({ id: i, state: i === focused ? "focused" : byId[i]?.urgent ? "urgent"
                       : wins.some(t => t.workspace?.id === i) ? "occupied" : "empty" });
        return out;
    }
    readonly property var wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNet: wifiDev ? (wifiDev.networks.values.find(n => n.connected) ?? null) : null
    readonly property var bat: UPower.displayDevice
    property bool caffeine: false
    Process { id: idleQ; running: true; command: ["pgrep", "-x", "hypridle"]; onExited: code => bar.caffeine = code !== 0 }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: idleQ.running = true }

    TopView {
        anchors.fill: parent
        tags: bar.tags
        time: Qt.formatDateTime(clock.date, "HH:mm")
        wifi: String.fromCodePoint(bar.wifiNet ? 0xf05a9 : 0xf05aa)
        caffeine: bar.caffeine
        batteryGlyph: String.fromCodePoint(bar.bat?.isLaptopBattery && bar.bat.state !== UPowerDeviceState.Charging ? 0xf0079 : 0xf06a5)
        onClicked: id => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`)
        onLaunch: w => {
            const urls = { reddit: "https://reddit.com", github: "https://github.com", mail: "https://mail.google.com" };
            if (w === "apps") Quickshell.execDetached(["bash", "-c", "pkill fuzzel || fuzzel"]);
            else if (w === "caffeine") { Quickshell.execDetached(["bash", "-c", "pkill -x hypridle || (setsid -f hypridle >/dev/null 2>&1)"]); bar.caffeine = !bar.caffeine }
            else Quickshell.execDetached(["xdg-open", urls[w]]);
        }
    }
    MouseArea { anchors { right: parent.right; top: parent.top; bottom: parent.bottom } width: 90; onClicked: bar.clockClicked() }
}
