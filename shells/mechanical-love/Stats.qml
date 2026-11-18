// System numbers for the sidebar: CPU, RAM, temperature, disk (one small shell poll every 3 s),
// weather every 30 min (wttr.in, location from your IP, like the original's openweathermap widget).
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: s
    property real cpu: 0
    property real ram: 0
    property real temp: 0          // 0..1 of 100 °C
    property string diskFree: ""
    property string weatherText: ""
    property string weatherIcon: "whatever"
    property var _prev: [0, 0]

    Process {
        id: poll
        command: ["bash", "-c",
            "read -r _ a b c d e f g _ < /proc/stat; echo cpu $((a+b+c+d+e+f+g)) $((d+e));" +
            "awk '/MemTotal/{t=$2}/MemAvailable/{v=$2}END{print \"ram\", (t-v)/t}' /proc/meminfo;" +
            "t=0; for h in /sys/class/hwmon/hwmon*; do case $(<\"$h/name\") in k10temp|coretemp|zenpower) t=$(<\"$h/temp1_input\"); break;; esac; done;" +
            "if ((t==0)); then for z in /sys/class/thermal/thermal_zone*/temp; do v=$(<\"$z\"); ((v>t)) && t=$v; done; fi; echo temp $t;" +
            "df -h --output=avail / | tail -1 | tr -d ' ' | sed 's/^/disk /'"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.split(" ");
                if (p[0] === "cpu") {
                    const tot = +p[1], idle = +p[2], dt = tot - s._prev[0], di = idle - s._prev[1];
                    if (s._prev[0] > 0 && dt > 0) s.cpu = 1 - di / dt;
                    s._prev = [tot, idle];
                } else if (p[0] === "ram") s.ram = +p[1];
                else if (p[0] === "temp") s.temp = Math.min(1, +p[1] / 100000);
                else if (p[0] === "disk") s.diskFree = p[1].replace(/([0-9.]+)([A-Z])$/, "$1$2B") + " free";
            }
        }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }

    Process {
        id: weather
        command: ["curl", "-s", "--max-time", "10", "https://wttr.in/?format=%C|%t|%S|%s"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|");
                if (p.length < 4) return;
                const cond = p[0].toLowerCase(), t = p[1].replace("+", "");
                const now = Qt.formatTime(new Date(), "HH:mm:ss"), night = now < p[2] || now > p[3];
                s.weatherText = cond + " " + t;
                s.weatherIcon = /thunder|storm/.test(cond) ? "storm" : /snow|sleet|ice/.test(cond) ? "snow"
                    : /rain|drizzle|shower/.test(cond) ? "rain" : /mist|fog|haze|smoke|dust|sand/.test(cond) ? "mist"
                    : /overcast/.test(cond) ? "cloud" : /cloud/.test(cond) ? (night ? "ncloud" : "dcloud")
                    : /clear|sunny/.test(cond) ? (night ? "star" : "sun") : "whatever";
            }
        }
    }
    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weather.running = true }
}
