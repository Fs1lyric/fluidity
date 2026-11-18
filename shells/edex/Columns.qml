// The SYSTEM and NETWORK columns; reserves the left 660 px.
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland

PanelWindow {
    id: w
    required property var stats
    property bool bottomShown: true
    anchors { top: true; left: true }
    implicitWidth: 660
    implicitHeight: (screen?.height ?? 1080) - (bottomShown ? 335 : 0)
    exclusiveZone: 660
    color: "transparent"
    WlrLayershell.namespace: "qs-edex-columns"
    WlrLayershell.layer: WlrLayer.Bottom
    SystemClock { id: clock; precision: SystemClock.Seconds }
    readonly property var bat: UPower.displayDevice
    ColumnsView {
        anchors.fill: parent
        time: Qt.formatDateTime(clock.date, "HH:mm:ss")
        year: Qt.formatDateTime(clock.date, "yyyy")
        date: Qt.formatDateTime(clock.date, "MMM d").toUpperCase()
        uptime: w.stats.uptime
        power: w.bat?.isLaptopBattery ? (w.bat.state === UPowerDeviceState.Charging ? "CHARGE" : Math.round(w.bat.percentage * 100) + "%") : "WIRED"
        cpuModel: w.stats.cpuModel
        cpuA: w.stats.cpuA; cpuB: w.stats.cpuB; avgA: w.stats.avgA; avgB: w.stats.avgB
        temp: w.stats.temp; fmin: w.stats.fmin; fmax: w.stats.fmax; tasks: w.stats.tasks
        memUsed: w.stats.memUsed; memText: w.stats.memText; procs: w.stats.procs
        netState: w.stats.netState; ipv4: w.stats.ipv4; ping: w.stats.ping; coords: w.stats.coords
        netUp: w.stats.netUp; netDown: w.stats.netDown; netTotal: w.stats.netTotal
        onCopy: Quickshell.execDetached(["wtype", "-M", "ctrl", "-k", "c", "-m", "ctrl"])
        onPaste: Quickshell.execDetached(["wtype", "-M", "ctrl", "-k", "v", "-m", "ctrl"])
    }
}
