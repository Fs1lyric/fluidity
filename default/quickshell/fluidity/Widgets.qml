pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Data for the optional desktop widgets (views/DesktopWidgets.qml) and which ones are on (fluidity-widgets list).
Singleton {
    id: wg
    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/fluidity"
    readonly property string confDir: (Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")) + "/fluidity"
    readonly property var all: ["clock", "media", "agenda", "system", "weather", "github", "notes", "dock", "timer", "usage", "battery", "visualizer", "user", "image", "text"]
    readonly property var defaults: ["clock", "media", "agenda", "system", "weather", "github", "notes"]
    property var shown: defaults
    FileView {
        path: wg.stateDir + "/desktop-widgets"; watchChanges: true; onFileChanged: reload()
        onLoaded: wg.shown = text().split("\n").filter(Boolean)
        onLoadFailed: wg.shown = wg.defaults
    }
    property var notes: []
    FileView {
        path: wg.home + "/.local/share/fluidity/notes.md"; watchChanges: true; onFileChanged: reload()
        onLoaded: wg.notes = text().split("\n").filter(l => l.trim()).slice(0, 10)
        onLoadFailed: wg.notes = []
    }
    property string text: ""
    FileView { path: wg.confDir + "/widget-text"; watchChanges: true; onFileChanged: reload(); onLoaded: wg.text = text().trim(); onLoadFailed: wg.text = "" }
    property string image: ""
    FileView { path: wg.confDir + "/widget-image"; watchChanges: true; onFileChanged: reload()
        onLoaded: { const p = text().trim().replace(/^~/, wg.home); wg.image = p ? "file://" + p : "" } onLoadFailed: wg.image = "" }

    // GitHub contributions (your gh login), refreshed every 6 h and cached for offline starts
    property var github: ({})
    Timer { interval: 21600000; running: wg.shown.includes("github"); repeat: true; triggeredOnStart: true; onTriggered: ghProc.running = true }
    Process {
        id: ghProc
        command: ["sh", "-c", "f=" + wg.stateDir + "/github.json; if gh api graphql -f query='query { viewer { login contributionsCollection { contributionCalendar { totalContributions weeks { contributionDays { contributionLevel } } } } } }' > \"$f.tmp\" 2>/dev/null; then mv \"$f.tmp\" \"$f\"; else rm -f \"$f.tmp\"; fi; cat \"$f\" 2>/dev/null"]
        stdout: StdioCollector { onStreamFinished: {
            try {
                const v = JSON.parse(text).data.viewer, cal = v.contributionsCollection.contributionCalendar;
                const lv = { NONE: 0, FIRST_QUARTILE: 1, SECOND_QUARTILE: 2, THIRD_QUARTILE: 3, FOURTH_QUARTILE: 4 };
                wg.github = { user: v.login, total: cal.totalContributions, weeks: cal.weeks.map(w => w.contributionDays.map(d => lv[d.contributionLevel] ?? 0)) };
            } catch (e) {}
        } }
    }

    property string uptime: ""
    property string host: ""
    property string face: ""
    Timer { interval: 60000; running: wg.shown.includes("user"); repeat: true; triggeredOnStart: true; onTriggered: upProc.running = true }
    Process {
        id: upProc
        command: ["sh", "-c", "cut -d. -f1 /proc/uptime; cat /etc/hostname 2>/dev/null || uname -n; [ -s \"$HOME/.face\" ] && echo face"]
        stdout: StdioCollector { onStreamFinished: { const l = String(text).split("\n"), s = Number(l[0]) || 0;
            wg.uptime = (s >= 86400 ? Math.floor(s / 86400) + "d " : "") + Math.floor(s % 86400 / 3600) + "h " + Math.floor(s % 3600 / 60) + "m"; wg.host = (l[1] || "").trim(); wg.face = l[2] === "face" ? "file://" + wg.home + "/.face" : "" } }
    }

    readonly property var data: ({
        weather: { now: Status.weather, text: Status.weatherText },
        github: github, notes: notes, timer: Status.focusText, usage: { percent: Status.ai, name: "claude" },
        battery: { percent: Status.battery, charging: UPower.displayDevice?.state === UPowerDeviceState.Charging },
        viz: Status.viz, user: { name: Quickshell.env("USER") || "", host: host, uptime: uptime, face: face },
        image: image, text: text })
}
