// eDEX numbers, polled every 2 s like its modules: CPU (cores 1-2 / 3-4 history), temperature, frequency range,
// tasks, memory, top processes, network state / IPv4 / ping / traffic, uptime. Endpoint location once (ipinfo.io).
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: s
    property var cpuA: []
    property var cpuB: []
    property int avgA: 0
    property int avgB: 0
    property string temp: "—"
    property string fmin: "—"
    property string fmax: "—"
    property int tasks: 0
    property real memUsed: 0
    property string memText: ""
    property var procs: []
    property string netState: "OFFLINE"
    property string ipv4: "—"
    property string ping: "—"
    property var netUp: []
    property var netDown: []
    property string netTotal: ""
    property string uptime: ""
    property string cpuModel: ""
    property string coords: "—"
    property real lat: NaN
    property real lon: NaN
    property var _prev: ({})
    property var _net: [0, 0]
    property bool _ip: false
    function push(arr, v) { const a = arr.slice(-29); a.push(v); return a }
    function gib(kb) { return (kb / 1048576).toFixed(1) }
    function human(b) { return b > 1e9 ? (b / 1e9).toFixed(1) + " GB" : (b / 1e6).toFixed(1) + " MB" }

    Process {
        id: model; running: true
        command: ["bash", "-c", "grep -m1 'model name' /proc/cpuinfo | cut -d: -f2-"]
        stdout: StdioCollector { onStreamFinished: s.cpuModel = text.trim().replace(/\(R\)/g, "®").replace(/\(TM\)/g, "™").replace(/ CPU.*$/, "") }
    }
    Process {
        id: loc; running: true
        command: ["curl", "-s", "--max-time", "8", "https://ipinfo.io/loc"]
        stdout: StdioCollector { onStreamFinished: { const p = text.trim().split(","); if (p.length === 2 && !isNaN(+p[0])) {
            s.lat = +p[0]; s.lon = +p[1]; s.coords = (+p[0]).toFixed(4) + ", " + (+p[1]).toFixed(4) } } }
    }
    Process {
        id: poll
        command: ["bash", "-c",
            "grep -E '^cpu[0-9]' /proc/stat | awk '{print \"core\", $1, $2+$3+$4+$5+$6+$7+$8, $5+$6}';" +
            "t=0; for h in /sys/class/hwmon/hwmon*; do case $(<\"$h/name\") in k10temp|coretemp|zenpower) t=$(<\"$h/temp1_input\"); break;; esac; done;" +
            "if ((t==0)); then for z in /sys/class/thermal/thermal_zone*/temp; do v=$(<\"$z\"); ((v>t)) && t=$v; done; fi; echo temp $t;" +
            "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sort -n | sed -n '1p;$p' | tr '\\n' ' ' | sed 's/^/freq /'; echo;" +
            "echo tasks $(ls -d /proc/[0-9]* | wc -l);" +
            "awk '/MemTotal/{t=$2}/MemAvailable/{v=$2}END{print \"mem\", t-v, t}' /proc/meminfo;" +
            "ps -eo pid=,%cpu=,%mem=,comm= --sort=-%cpu | head -5 | sed 's/^ */proc /';" +
            "ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \\K[0-9.]+' | sed 's/^/ip /';" +
            "awk 'NR>2 && $1 !~ /lo:/ {r+=$2; t+=$10} END {print \"net\", r, t}' /proc/net/dev;" +
            "awk '{s=int($1); printf \"up %d:%02d:%02d\\n\", s/3600, (s%3600)/60, s%60}' /proc/uptime"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/);
                if (p[0] === "core") {
                    const id = p[1], tot = +p[2], idle = +p[3], pr = s._prev[id];
                    if (pr) { const dt = tot - pr[0]; s._prev[id + "u"] = dt > 0 ? 1 - (idle - pr[1]) / dt : 0 }
                    s._prev[id] = [tot, idle];
                } else if (p[0] === "temp") {
                    s.temp = Math.round(+p[1] / 1000) + "°C";
                    // the core lines are done: fold cores 1-2 and 3-4 into the two graphs
                    const u = i => s._prev["cpu" + i + "u"] ?? 0;
                    const a = (u(0) + u(1)) / 2, b = (u(2) + u(3)) / 2;
                    s.cpuA = s.push(s.cpuA, a); s.cpuB = s.push(s.cpuB, b);
                    s.avgA = Math.round(s.cpuA.reduce((x, y) => x + y, 0) / s.cpuA.length * 100);
                    s.avgB = Math.round(s.cpuB.reduce((x, y) => x + y, 0) / s.cpuB.length * 100);
                    s.procs = []; s._ip = false;
                } else if (p[0] === "freq" && p.length >= 3) { s.fmin = (+p[1] / 1e6).toFixed(2) + "GHz"; s.fmax = (+p[2] / 1e6).toFixed(2) + "GHz" }
                else if (p[0] === "tasks") s.tasks = +p[1];
                else if (p[0] === "mem") { s.memUsed = +p[1] / +p[2]; s.memText = "USING " + s.gib(+p[1]) + " OUT OF " + s.gib(+p[2]) + " GiB" }
                else if (p[0] === "proc") { const a = s.procs.slice(); a.push([p[1], p.slice(4).join(" "), p[2] + "%", p[3] + "%"]); s.procs = a }
                else if (p[0] === "ip") { s.ipv4 = p[1]; s._ip = true }
                else if (p[0] === "net") {
                    const r = +p[1], t = +p[2];
                    if (s._net[0] > 0) { s.netDown = s.push(s.netDown, Math.min(1, (r - s._net[0]) / 2 / 5e6)); s.netUp = s.push(s.netUp, Math.min(1, (t - s._net[1]) / 2 / 5e6)) }
                    s._net = [r, t]; s.netTotal = s.human(t) + " OUT, " + s.human(r) + " IN";
                } else if (p[0] === "up") { s.uptime = p[1]; s.netState = s._ip ? "ONLINE" : "OFFLINE"; if (!s._ip) s.ipv4 = "—" }
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: poll.running = true }

    Process {
        id: pinger
        command: ["bash", "-c", "ping -c1 -W2 1.1.1.1 | grep -oP 'time=\\K[0-9.]+'"]
        stdout: StdioCollector { onStreamFinished: s.ping = text.trim() ? Math.round(+text.trim()) + "ms" : "—" }
    }
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: pinger.running = true }
}
