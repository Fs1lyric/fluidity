pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Slow-moving facts for the bar and the desktop: clock, Wi-Fi, battery, AI usage, system load, today's plan.
Singleton {
    id: st
    property date now: new Date()
    readonly property string clock: Qt.formatDateTime(now, "ddd d · HH:mm")
    readonly property string hours: Qt.formatDateTime(now, "HH")
    readonly property string minutes: Qt.formatDateTime(now, "mm")
    readonly property string weekday: Qt.formatDateTime(now, "dddd")
    readonly property string date: Qt.formatDateTime(now, "d MMMM")
    property string wifi: ""
    readonly property int battery: UPower.displayDevice?.isLaptopBattery ? Math.round(UPower.displayDevice.percentage * 100) : -1
    property int ai: -1
    property var sys: ({ cpu: 0, ram: 0, temp: 0, disk: 0 })
    property var agenda: []
    property var cpuLast: null

    Timer { interval: 1000; running: true; repeat: true; onTriggered: st.now = new Date() }

    // every 5 s: cpu, ram, temp, disk, wifi
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: sysProc.running = true }
    Process {
        id: sysProc
        command: ["sh", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; " +
                  "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0; df --output=pcent / | tail -1; " +
                  "nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^wifi:connected' && echo wifi-up || (nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^ethernet:connected' && echo eth-up || echo net-down)"]
        stdout: StdioCollector { onStreamFinished: {
            const l = String(text).split("\n");
            const c = l[0].split(/\s+/).slice(1).map(Number), idle = c[3] + (c[4] || 0), total = c.reduce((a, b) => a + b, 0);
            let cpu = st.sys.cpu;
            if (st.cpuLast) cpu = 100 * (1 - (idle - st.cpuLast.idle) / Math.max(1, total - st.cpuLast.total));
            st.cpuLast = { idle: idle, total: total };
            const mt = Number((l[1].match(/\d+/) || [1])[0]), ma = Number((l[2].match(/\d+/) || [0])[0]);
            st.sys = { cpu: Math.max(0, cpu), ram: 100 * (1 - ma / mt), temp: Number(l[3]) / 1000, disk: parseInt(l[4]) || 0 };
            st.wifi = l[5] === "wifi-up" ? "󰤨" : l[5] === "eth-up" ? "󰈀" : "󰤭";
        } }
    }

    // every minute: AI usage and today's Calendio plan (read-only)
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { aiProc.running = true; agendaProc.running = true } }
    Process {
        id: aiProc
        command: ["fluidity-ai-usage"]
        stdout: StdioCollector { onStreamFinished: { try { const j = JSON.parse(text); st.ai = j.worst ?? -1 } catch (e) { st.ai = -1 } } }
    }
    Process {
        id: agendaProc
        command: ["sqlite3", "-readonly", "-separator", "\t", Quickshell.env("HOME") + "/.local/share/calendio/cal.db",
                  "select strftime('%H:%M', start, 'localtime'), strftime('%H:%M', end, 'localtime'), title, ifnull(color, '') from events " +
                  "where all_day = 0 and date(start, 'localtime') = date('now', 'localtime') order by start"]
        stdout: StdioCollector { onStreamFinished: {
            const hm = Qt.formatDateTime(new Date(), "HH:mm");
            const rows = String(text).split("\n").filter(Boolean).map(r => r.split("\t"));
            let start = rows.findIndex(r => r[1] > hm);       // the block on now, or the next one
            if (start < 0) start = Math.max(0, rows.length - 5);
            st.agenda = rows.slice(Math.max(0, start - 1), Math.max(0, start - 1) + 5).map(r => ({
                time: r[0], title: r[2], color: r[3] || undefined,
                now: r[0] <= hm && hm < r[1], done: r[1] <= hm,
                sub: r[0] <= hm && hm < r[1] ? "now · until " + r[1] : "until " + r[1] }));
        } }
    }
}
