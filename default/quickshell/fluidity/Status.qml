pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Services.Mpris
import Quickshell.Hyprland

// Slow-moving facts for the bar and the desktop: clock, Wi-Fi, battery, AI usage, system load, today's plan.
Singleton {
    id: st
    property date now: new Date()
    readonly property string clock: Qt.formatDateTime(now, "ddd d · h:mm AP")
    readonly property string hours: Qt.formatDateTime(now, "h")
    readonly property string minutes: Qt.formatDateTime(now, "mm")
    readonly property string weekday: Qt.formatDateTime(now, "dddd")
    readonly property string date: Qt.formatDateTime(now, "d MMMM")
    property string wifi: ""
    readonly property int battery: UPower.displayDevice?.isLaptopBattery ? Math.round(UPower.displayDevice.percentage * 100) : -1
    property int ai: -1
    // bar faces
    property string weather: ""
    property string weatherText: ""
    property var viz: []
    property string kb: ""
    property int bt: -1
    readonly property bool playing: Mpris.players.values.some(p => p.isPlaying)
    function notify(title, body, icon) { Quickshell.execDetached(["notify-send", "-a", "Fluidity", "-i", icon || "dialog-information", title, body || ""]) }

    // weather from wttr.in (by your IP) every 30 min; a storm, heavy rain or snow is announced once a day
    readonly property var weatherGlyphs: [[/thunder/i, "󰙾"], [/snow|sleet|blizzard/i, "󰖘"], [/rain|drizzle|shower/i, "󰖗"], [/fog|mist|haze/i, "󰖑"],
                                          [/overcast|cloud/i, "󰖐"], [/partly/i, "󰖕"], [/clear|sunny/i, "󰖙"]]
    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weatherProc.running = true }
    Process {
        id: weatherProc
        command: ["curl", "-fsm", "8", "https://wttr.in/?format=%t|%C"]
        stdout: StdioCollector { onStreamFinished: {
            const p = String(text).trim().split("|");
            if (p.length < 2 || !/°/.test(p[0])) return;
            const cond = p[1], g = (st.weatherGlyphs.find(x => x[0].test(cond)) || [null, "󰖐"])[1];
            st.weather = g + " " + p[0].replace(/^\+/, "").replace(/C$|F$/, "");
            st.weatherText = cond;
            const bad = /thunder|heavy|torrential|blizzard|snow/i.test(cond), day = Qt.formatDate(new Date(), "yyyy-MM-dd");
            if (bad && st.alerted !== day + cond) { st.alerted = day + cond; st.notify("Weather: " + cond, p[0] + " outside right now", "weather-storm"); }
        } }
    }
    property string alerted: ""

    // battery: low at 15 % (and 5 %), charged at 100 %
    property int battWarned: 101
    onBatteryChanged: {
        const dev = UPower.displayDevice;
        if (battery < 0 || !dev) return;
        const charging = dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged || dev.state === UPowerDeviceState.PendingCharge;
        if (!charging && (battery <= 5 && battWarned > 5 || battery <= 15 && battWarned > 15)) { battWarned = battery; notify("Battery low", battery + "% left. Plug in soon.", "battery-caution"); }
        if (charging) battWarned = 101;
        if (charging && battery >= 100 && !fullSaid) { fullSaid = true; notify("Battery charged", "100%. You can unplug.", "battery-full-charged"); }
        if (battery < 95) fullSaid = false;
    }
    property bool fullSaid: false

    // keyboard layout: shown only when more than one is set up
    Process {
        id: kbProc
        running: true
        command: ["sh", "-c", "hyprctl getoption input:kb_layout -j 2>/dev/null | jq -r '.str // empty'; hyprctl devices -j 2>/dev/null | jq -r '[.keyboards[] | select(.main)][0].active_keymap // empty'"]
        stdout: StdioCollector { onStreamFinished: { const l = String(text).split("\n"); st.multiKb = (l[0] || "").includes(","); if (st.multiKb) st.kb = st.shortKb(l[1] || ""); } }
    }
    property bool multiKb: false
    function shortKb(name) { const m = { english: "us", german: "de", french: "fr", spanish: "es", bengali: "bn", arabic: "ar", russian: "ru", japanese: "ja" };
        const w = name.toLowerCase().split(/[ (]/)[0]; return m[w] || w.slice(0, 2) }
    Connections {
        target: Hyprland
        function onRawEvent(e) { if (e.name === "activelayout" && st.multiKb) st.kb = st.shortKb(e.data.split(",").slice(1).join(",")) }
    }

    // bluetooth: hidden when there is no adapter or it is off
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!btProc.running) btProc.running = true }
    Process {
        id: btProc
        command: ["sh", "-c", "timeout 3 bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' || { echo -1; exit; }; timeout 3 bluetoothctl devices Connected 2>/dev/null | grep -c '^Device'"]
        stdout: StdioCollector { onStreamFinished: st.bt = parseInt(text) >= 0 ? parseInt(text) : -1 }
    }

    // a six-bar visualizer for the bar while music plays
    Process {
        id: vizProc
        running: st.playing
        command: ["sh", "-c", "c=${XDG_RUNTIME_DIR:-/tmp}/fluidity-cava-bar.conf; printf '[general]\\nbars = 6\\nframerate = 20\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\nbar_delimiter = 59\\n' > \"$c\"; exec cava -p \"$c\""]
        stdout: SplitParser { onRead: line => st.viz = line.split(";").filter(x => x !== "").map(x => Number(x) / 100) }
        onRunningChanged: if (!running) st.viz = []
    }
    property var sys: ({ cpu: 0, ram: 0, temp: 0, disk: 0 })
    property var agenda: []
    property var cpuLast: null
    // focus timer (fluidity-focus) and the next Calendio block, for the idle island
    property int focusUntil: 0
    readonly property string focusText: {
        const left = focusUntil - Math.floor(now.getTime() / 1000);
        return focusUntil && left > 0 ? "focus " + Math.floor(left / 60) + ":" + String(left % 60).padStart(2, "0") : "";
    }
    property var todayRows: []
    readonly property string nextText: {
        const hm = Qt.formatDateTime(now, "HH:mm"), mins = t => Number(t.slice(0, 2)) * 60 + Number(t.slice(3, 5)), n = mins(hm);
        const cur = todayRows.find(r => r[0] <= hm && hm < r[1]);
        if (cur) return cur[2] + " · " + (mins(cur[1]) - n) + "m left";
        const nx = todayRows.find(r => r[0] > hm);
        return nx && mins(nx[0]) - n <= 60 ? nx[2] + " in " + (mins(nx[0]) - n) + "m" : "";
    }
    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/fluidity/focus-until"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: st.focusUntil = parseInt(text()) || 0
        onLoadFailed: st.focusUntil = 0
    }

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
            st.todayRows = rows;
            let start = rows.findIndex(r => r[1] > hm);       // the block on now, or the next one
            if (start < 0) start = Math.max(0, rows.length - 5);
            st.agenda = rows.slice(Math.max(0, start - 1), Math.max(0, start - 1) + 5).map(r => ({
                time: r[0], title: r[2], color: r[3] || undefined,
                now: r[0] <= hm && hm < r[1], done: r[1] <= hm,
                sub: r[0] <= hm && hm < r[1] ? "now · until " + r[1] : "until " + r[1] }));
        } }
    }
}
