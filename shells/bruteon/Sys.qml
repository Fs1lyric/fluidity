// Live desktop data for a theme shell (copied into each shells/<name> by tools/sync-common.sh; edit it here).
// Views never import Quickshell: they read this object's plain properties and call act(what, arg).
// FakeSys.qml has the same properties with fixed values for the off-screen previews.
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Item {
    id: s
    // time
    SystemClock { id: clock; precision: SystemClock.Seconds }
    readonly property date now: clock.date
    // workspaces 1..10: { id, state: focused | urgent | occupied | empty, count }
    readonly property var tags: {
        const focused = Hyprland.focusedWorkspace?.id ?? -1, wins = Hyprland.toplevels.values, byId = {};
        for (const w of Hyprland.workspaces.values) byId[w.id] = w;
        const out = [];
        for (let i = 1; i <= 10; i++) {
            const n = wins.filter(t => t.workspace?.id === i).length;
            out.push({ id: i, count: n, state: i === focused ? "focused" : byId[i]?.urgent ? "urgent" : n ? "occupied" : "empty" });
        }
        return out;
    }
    readonly property int workspace: Hyprland.focusedWorkspace?.id ?? 1
    readonly property string title: Hyprland.activeToplevel?.title ?? ""
    readonly property string appClass: Hyprland.activeToplevel?.lastIpcObject?.class ?? ""
    // media
    readonly property var _p: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property bool hasPlayer: _p !== null
    readonly property string track: _p?.trackTitle || ""
    readonly property string artist: _p?.trackArtist || ""
    readonly property string art: _p?.trackArtUrl || ""
    readonly property bool playing: _p?.isPlaying ?? false
    readonly property real length: _p?.length ?? 0
    property real position: 0
    Timer { interval: 1000; running: s._p !== null; repeat: true; triggeredOnStart: true
            onTriggered: { s._p.positionChanged(); s.position = s._p.position } }
    // audio
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    PwObjectTracker { objects: [s.sink, s.source] }
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool micMuted: source?.audio?.muted ?? false
    // power
    readonly property var _bat: UPower.displayDevice
    readonly property bool hasBattery: _bat?.isLaptopBattery ?? false
    readonly property real battery: hasBattery ? _bat.percentage : 1
    readonly property bool charging: !hasBattery || _bat.state === UPowerDeviceState.Charging || _bat.state === UPowerDeviceState.FullyCharged
    // network + bluetooth
    readonly property var _wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var _wifiNet: _wifiDev ? (_wifiDev.networks.values.find(n => n.connected) ?? null) : null
    readonly property bool wired: Networking.devices.values.some(d => d.type === DeviceType.Wired && d.connected)
    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property string ssid: _wifiNet?.name ?? ""
    readonly property real wifiStrength: _wifiNet?.signalStrength ?? 0
    readonly property bool online: wired || _wifiNet !== null
    readonly property bool btOn: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property int btConnected: Bluetooth.devices.values.filter(d => d.connected).length
    // system (one small poll every 2 s)
    property real cpu: 0
    property real ram: 0
    property real ramUsed: 0        // GiB
    property real ramTotal: 0       // GiB
    property real temp: 0           // °C
    property real diskUsed: 0
    property string diskFree: ""
    property string uptime: ""
    property real netDown: 0        // bytes/s
    property real netUp: 0
    property string user: ""
    property string host: ""
    property string kernel: ""
    property int packages: 0
    property var _prev: [0, 0, 0, 0, 0]
    Process {
        id: poll
        command: ["bash", "-c",
            "read -r _ a b c d e f g _ < /proc/stat; echo cpu $((a+b+c+d+e+f+g)) $((d+e));" +
            "awk '/MemTotal/{t=$2}/MemAvailable/{v=$2}END{print \"ram\", t-v, t}' /proc/meminfo;" +
            "t=0; for h in /sys/class/hwmon/hwmon*; do case $(<\"$h/name\") in k10temp|coretemp|zenpower) t=$(<\"$h/temp1_input\"); break;; esac; done;" +
            "if ((t==0)); then for z in /sys/class/thermal/thermal_zone*/temp; do v=$(<\"$z\"); ((v>t)) && t=$v; done; fi; echo temp $t;" +
            "echo disk $(df --output=pcent,avail -h / | tail -1);" +
            "awk 'NR>2 && $1 !~ /lo:/{r+=$2; t+=$10}END{print \"net\", r, t}' /proc/net/dev;" +
            "echo up $(uptime -p | sed 's/^up //')"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.trim().split(/\s+/);
                if (p[0] === "cpu") {
                    const tot = +p[1], idle = +p[2], dt = tot - s._prev[0], di = idle - s._prev[1];
                    if (s._prev[0] > 0 && dt > 0) s.cpu = 1 - di / dt;
                    s._prev[0] = tot; s._prev[1] = idle;
                } else if (p[0] === "ram") { s.ram = (+p[1]) / (+p[2]); s.ramUsed = +p[1] / 1048576; s.ramTotal = +p[2] / 1048576 }
                else if (p[0] === "temp") s.temp = +p[1] / 1000;
                else if (p[0] === "disk") { s.diskUsed = parseInt(p[1]) / 100; s.diskFree = p[2] }
                else if (p[0] === "net") {
                    const now = Date.now(), r = +p[1], t = +p[2];
                    if (s._prev[4] > 0) { const dt = (now - s._prev[4]) / 1000; s.netDown = Math.max(0, (r - s._prev[2]) / dt); s.netUp = Math.max(0, (t - s._prev[3]) / dt) }
                    s._prev[2] = r; s._prev[3] = t; s._prev[4] = now;
                } else if (p[0] === "up") s.uptime = p.slice(1).join(" ");
            }
        }
    }
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: poll.running = true }
    Process {
        running: true
        command: ["bash", "-c", "echo \"$USER|$(cat /etc/hostname 2>/dev/null || uname -n)|$(uname -r)|$(pacman -Qq 2>/dev/null | wc -l)\""]
        stdout: StdioCollector { onStreamFinished: { const p = text.trim().split("|"); s.user = p[0]; s.host = p[1]; s.kernel = p[2]; s.packages = +p[3] } }
    }
    // weather every 30 min (wttr.in, pinned to Dhaka; a VPN exit made the IP guess say Romania)
    property string weatherCond: ""
    property string weatherTemp: ""      // "25"
    property string weatherPlace: ""
    property string weatherHumidity: ""
    property string weatherWind: ""
    property bool night: false
    property string sunrise: ""          // "05:24:10"
    property string sunset: ""
    Process {
        id: weather
        command: ["curl", "-s", "--max-time", "10", "https://wttr.in/Dhaka?format=%C|%t|%S|%s|%l|%h|%w"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|");
                if (p.length < 7) return;
                const now = Qt.formatTime(new Date(), "HH:mm:ss");
                s.weatherCond = p[0].trim();
                s.weatherTemp = p[1].replace("+", "").replace(/°[CF]/, "");
                s.night = now < p[2] || now > p[3];
                s.sunrise = p[2]; s.sunset = p[3];
                s.weatherPlace = p[4].split(",")[0];
                s.weatherHumidity = p[5]; s.weatherWind = p[6].replace(/[^0-9]/g, "") + " km/h";
            }
        }
    }
    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weather.running = true }

    // caffeine = hypridle stopped (screen never sleeps)
    property bool caffeine: false
    Process { id: idleQ; command: ["pgrep", "-x", "hypridle"]; onExited: code => s.caffeine = code !== 0 }
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: idleQ.running = true }

    // to-do list shared by the shells that have one (~/.local/share/fluidity/todos.json): [{ text, done }]
    property var todos: []
    FileView {
        id: todoFile
        path: Quickshell.env("HOME") + "/.local/share/fluidity/todos.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { s.todos = JSON.parse(text()) } catch (e) { s.todos = [] } }
        onLoadFailed: s.todos = []
    }
    function _saveTodos(list) { s.todos = list; Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/share/lyric"]); todoFile.setText(JSON.stringify(list)) }

    // Everything a view can ask for.
    function act(what, arg) {
        const sh = c => Quickshell.execDetached(["bash", "-c", c]);
        switch (what) {
        case "ws": Hyprland.dispatch(`hl.dsp.focus({ workspace = "${arg}" })`); break;
        case "wsStep": Hyprland.dispatch(`hl.dsp.focus({ workspace = "${arg > 0 ? "e+1" : "e-1"}" })`); break;
        case "launcher": sh("pkill fuzzel || fuzzel"); break;
        case "power": sh("pkill fuzzel || case $(printf 'Lock\\nSuspend\\nLog out\\nReboot\\nPower off' | fuzzel --dmenu -l 5 -p 'power ') in " +
                         "Lock) loginctl lock-session;; Suspend) systemctl suspend;; 'Log out') hyprctl dispatch 'hl.dsp.exit()';; " +
                         "Reboot) systemctl reboot;; 'Power off') systemctl poweroff;; esac"); break;
        case "lock": sh("loginctl lock-session"); break;
        case "play": s._p?.togglePlaying(); break;
        case "next": s._p?.next(); break;
        case "prev": s._p?.previous(); break;
        case "seek": if (s._p) s._p.position = arg * s.length; break;
        case "volume": if (s.sink?.audio) s.sink.audio.volume = Math.max(0, Math.min(1, arg)); break;
        case "volumeStep": if (s.sink?.audio) s.sink.audio.volume = Math.max(0, Math.min(1, s.volume + arg)); break;
        case "mute": if (s.sink?.audio) s.sink.audio.muted = !s.muted; break;
        case "mic": if (s.source?.audio) s.source.audio.muted = !s.micMuted; break;
        case "wifi": Networking.wifiEnabled = !Networking.wifiEnabled; break;
        case "bt": if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled; break;
        case "brightness": sh(`brightnessctl set ${Math.round(arg * 100)}%`); break;
        case "settings": sh("lyric-settings"); break;
        case "files": sh("thunar || nautilus || xdg-open ~"); break;
        case "terminal": sh("ghostty || kitty || foot"); break;
        case "browser": sh("xdg-open https://"); break;
        case "url": Quickshell.execDetached(["xdg-open", arg]); break;
        case "exec": Quickshell.execDetached(arg); break;
        case "shot": sh("grim -g \"$(slurp)\" - | wl-copy"); break;
        case "dnd": sh("qs -c fluidity ipc call notifications toggleDnd"); break;
        case "clearNotifs": sh("qs -c fluidity ipc call notifications clear"); break;
        case "night": sh(arg ? "pkill hyprsunset; setsid -f hyprsunset -t 4000" : "pkill hyprsunset"); break;
        case "todoAdd": if (String(arg).trim()) s._saveTodos(s.todos.concat([{ text: String(arg).trim(), done: false }])); break;
        case "todoToggle": s._saveTodos(s.todos.map((t, i) => i === arg ? { text: t.text, done: !t.done } : t)); break;
        case "todoRemove": s._saveTodos(s.todos.filter((t, i) => i !== arg)); break;
        case "caffeine": sh("pkill -x hypridle || (setsid -f hypridle >/dev/null 2>&1)"); s.caffeine = !s.caffeine; break;
        case "close": Hyprland.dispatch("hl.dsp.window.close()"); break;
        }
    }
}
