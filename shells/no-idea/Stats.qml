// System numbers: CPU, RAM, temperature, disk, brightness, uptime (one small shell poll every 3 s),
// pandemic numbers (disease.sh, hourly), fortune-style quote (fortune if installed),
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
    property real diskUsed: 0
    property real brightness: 1
    property string uptime: ""
    property string cases: "—"
    property string deaths: "—"
    property string quote: "Life would be so much easier if we could just look at the source code.\n— Dave Olson"
    property string weatherText: ""
    property string weatherIcon: "whatever"
    property string weatherCond: ""
    property string weatherTemp: ""
    property var _prev: [0, 0]

    Process {
        id: poll
        command: ["bash", "-c",
            "read -r _ a b c d e f g _ < /proc/stat; echo cpu $((a+b+c+d+e+f+g)) $((d+e));" +
            "awk '/MemTotal/{t=$2}/MemAvailable/{v=$2}END{print \"ram\", (t-v)/t}' /proc/meminfo;" +
            "t=0; for h in /sys/class/hwmon/hwmon*; do case $(<\"$h/name\") in k10temp|coretemp|zenpower) t=$(<\"$h/temp1_input\"); break;; esac; done;" +
            "if ((t==0)); then for z in /sys/class/thermal/thermal_zone*/temp; do v=$(<\"$z\"); ((v>t)) && t=$v; done; fi; echo temp $t;" +
            "df -h --output=avail / | tail -1 | tr -d ' ' | sed 's/^/disk /';" +
            "df --output=pcent / | tail -1 | tr -d ' %' | sed 's/^/diskp /';" +
            "command -v brightnessctl >/dev/null && echo bright $(brightnessctl -m | cut -d, -f4 | tr -d %);" +
            "echo up $(uptime -p | sed 's/^up //')"]
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
                else if (p[0] === "diskp") s.diskUsed = +p[1] / 100;
                else if (p[0] === "bright" && p[1]) s.brightness = +p[1] / 100;
                else if (p[0] === "up") s.uptime = "up " + p.slice(1).join(" ");
            }
        }
    }
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }

    Process {
        id: weather
        command: ["curl", "-s", "--max-time", "10", "https://wttr.in/Dhaka?format=%C|%t|%S|%s"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|");
                if (p.length < 4) return;
                const cond = p[0].toLowerCase(), t = p[1].replace("+", "");
                const now = Qt.formatTime(new Date(), "HH:mm:ss"), night = now < p[2] || now > p[3];
                s.weatherText = cond + " " + t;
                s.weatherCond = p[0].trim().charAt(0).toUpperCase() + p[0].trim().slice(1).toLowerCase();
                s.weatherTemp = t.replace("°C", "").replace("°F", "");
                s.weatherIcon = /thunder|storm/.test(cond) ? "storm" : /snow|sleet|ice/.test(cond) ? "snow"
                    : /rain|drizzle|shower/.test(cond) ? "rain" : /mist|fog|haze|smoke|dust|sand/.test(cond) ? "mist"
                    : /overcast/.test(cond) ? "cloud" : /cloud/.test(cond) ? (night ? "ncloud" : "dcloud")
                    : /clear|sunny/.test(cond) ? (night ? "star" : "sun") : "whatever";
            }
        }
    }
    Process {
        id: covid
        command: ["curl", "-s", "--max-time", "10", "https://disease.sh/v3/covid-19/countries/germany"]
        stdout: StdioCollector {
            onStreamFinished: { try { const j = JSON.parse(text);
                s.cases = j.cases.toLocaleString(Qt.locale("C"), "f", 0).replace(/,/g, "") + " (+" + j.todayCases + ")";
                s.deaths = j.deaths.toLocaleString(Qt.locale("C"), "f", 0).replace(/,/g, "") + " (+" + j.todayDeaths + ")"; } catch (e) {} }
        }
    }
    Timer { interval: 3600000; running: true; repeat: true; triggeredOnStart: true; onTriggered: covid.running = true }
    Process {
        id: fortune
        command: ["bash", "-c", "command -v fortune >/dev/null && fortune -n 140 -s"]
        stdout: StdioCollector { onStreamFinished: if (text.trim()) s.quote = text.trim() }
    }
    Timer { interval: 3600000; running: true; repeat: true; triggeredOnStart: true; onTriggered: fortune.running = true }

    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weather.running = true }
}
