import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

// The Apple menu's windows (drawn by MacDialogView.qml), opened from Bar.qml through Panels:
// "about", "forcequit", "restart", "shutdown", "logout". Centred on the focused screen like a
// macOS system window. The alert counts down from 60 and then does it, as macOS does.
Scope {
    id: root

    readonly property string mode: ["about", "forcequit", "restart", "shutdown", "logout"].includes(Panels.open)
        ? Panels.open : ""
    readonly property bool isAlert: mode === "restart" || mode === "shutdown" || mode === "logout"
    property int seconds: 60
    property var about: ({})

    readonly property var commands: ({
        restart: ["systemctl", "reboot"],
        shutdown: ["systemctl", "poweroff"],
        logout: ["uwsm", "stop"]
    })

    function keyOf(t) {
        const id = t?.wayland?.appId ?? t?.lastIpcObject?.class ?? "";
        return DesktopEntries.heuristicLookup(id)?.id ?? id;
    }
    // One row per running app, the way Force Quit lists them.
    readonly property var apps: {
        const seen = {};
        const out = [];
        for (const t of Hyprland.toplevels.values) {
            const k = keyOf(t);
            if (!k || seen[k]) continue;
            seen[k] = true;
            const e = DesktopEntries.byId(k) ?? DesktopEntries.heuristicLookup(k);
            out.push({
                key: k,
                name: k === "org.gnome.Nautilus" ? "Finder" : (e?.name ?? k),
                iconUrl: Quickshell.iconPath(e?.icon ?? k, "application-x-executable")
            });
        }
        return out.sort((a, b) => a.name.localeCompare(b.name));
    }

    function forceQuit(i) {
        const app = apps[i];
        if (!app) return;
        Hyprland.refreshToplevels();
        const pids = Hyprland.toplevels.values.filter(t => keyOf(t) === app.key)
            .map(t => t.lastIpcObject?.pid).filter(p => p > 0);
        if (pids.length) Quickshell.execDetached(["kill", "-9"].concat(pids.map(String)));
        view.selected = Math.max(0, Math.min(view.selected, apps.length - 2));
    }
    function confirm() {
        const cmd = commands[mode];
        Panels.close();
        if (cmd) Quickshell.execDetached(cmd);
    }

    onModeChanged: {
        seconds = 60;
        view.selected = 0;
        if (mode === "about" && !about.name) info.running = true;
        if (mode === "forcequit") Hyprland.refreshToplevels();
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.isAlert
        onTriggered: if (--root.seconds <= 0) root.confirm()
    }

    Process {
        id: info
        command: ["sh", "-c", `. /etc/os-release; echo "$PRETTY_NAME"; uname -r;
            echo "$(cat /sys/devices/virtual/dmi/id/board_vendor) $(cat /sys/devices/virtual/dmi/id/board_name)";
            lscpu | sed -n "s/^Model name: *//p";
            awk '/MemTotal/ { printf "%d GB\\n", int($2 / 1048576 + 0.99) }' /proc/meminfo;
            findmnt -no LABEL / || echo "/"`]
        stdout: StdioCollector {
            onStreamFinished: {
                const l = text.split("\n");
                const cpu = l[3] ?? "";
                const gfx = cpu.match(/with (.+)$/);
                root.about = {
                    name: l[0],
                    kernel: l[1],
                    model: (l[2] ?? "").replace(/ Technology Co\., Ltd\.| Co\., Ltd\.| Inc\./, ""),
                    chip: cpu.replace(/ with .+$/, ""),
                    graphics: gfx ? gfx[1] : "",
                    memory: l[4],
                    disk: l[5] || "/"
                };
            }
        }
    }

    PanelWindow {
        visible: root.mode !== ""
        screen: Panels.screen ?? Quickshell.screens[0]
        implicitWidth: view.implicitWidth
        implicitHeight: view.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "qs-lyric-dialog"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MacDialogView {
            id: view
            anchors.fill: parent
            focus: true
            mode: root.mode || "about"
            about: root.about
            deviceIcon: Quickshell.iconPath("computer")
            apps: root.apps
            seconds: root.seconds
            onCloseRequested: Panels.close()
            onConfirmed: root.confirm()
            onForceQuit: i => root.forceQuit(i)
            onMoreInfo: {
                Panels.close();
                Quickshell.execDetached(["ghostty", "--wait-after-command=true", "-e", "fastfetch"]);
            }
        }
    }
}
