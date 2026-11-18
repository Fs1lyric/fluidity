// Outline: "wallpaper transitions that draw the character's outline first" (r/unixporn 1xq8mqp) in Quickshell.
// The shell draws the wallpaper itself (under the windows, over awww) so it can change it the post's way:
// prep.py cuts each picture's outline once and caches it; a picture with a subject gets its outline drawn first
// and the world grown out of it, one without spreads in as pixel colonies. The bar repaints from every picture.
// fluidity-theme starts it (`qs -c outline`); Super+` (or the bar's picture button) moves to the next wallpaper
// in the same folder. Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property string wallPath: ""
    property string pending: ""
    property var pal: ["#0f1012", "#e6e6e6", "#e0c080", "#7aa2d8"]
    property var nextPal: pal
    signal change(string url, string edges, var info)
    Sys { id: live }

    function act(w, a) { if (w === "nextWall") nextWall.running = true; else live.act(w, a) }
    Process {
        id: nextWall
        command: ["bash", "-c", "cur=$(awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1); d=$(dirname \"$cur\"); " +
                  "n=$(ls \"$d\" | grep -iE '\\.(jpe?g|png|webp)$' | sort | awk -v c=\"$(basename \"$cur\")\" 'f{print;exit} $0==c{f=1}'); " +
                  "[ -z \"$n\" ] && n=$(ls \"$d\" | grep -iE '\\.(jpe?g|png|webp)$' | sort | head -1); fluidity-shell wallpaper set \"$d/$n\""]
    }
    Process {
        id: wallQ
        command: ["bash", "-c", "awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1"]
        stdout: StdioCollector { onStreamFinished: {
            const p = text.trim();
            if (p && p !== root.wallPath && p !== root.pending && !prep.running) { root.pending = p; prep.running = true }
        } }
    }
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: wallQ.running = true }
    Process {
        id: prep
        command: ["bash", "-c", "d=$(/usr/bin/python3 \"$1\" \"$2\" 2>/dev/null) && echo \"$d\" && cat \"$d/info\" \"$d/palette\"", "prep",
                  Quickshell.shellDir + "/prep.py", root.pending]
        stdout: StdioCollector { onStreamFinished: {
            const l = text.trim().split("\n");
            const first = root.wallPath === "";
            root.wallPath = root.pending; root.pending = "";
            if (l.length < 3) { root.change("file://" + root.wallPath, "", { mode: "colonies", cx: 960, cy: 540, instant: first }); return }
            const i = l[1].split(" ");
            root.nextPal = l[2].split(" ");
            if (first) root.pal = root.nextPal;
            root.change("file://" + root.wallPath, "file://" + l[0] + "/edges.png", { mode: i[0], cx: +(i[1] ?? 960), cy: +(i[2] ?? 540), instant: first });
        } }
    }

    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-outline-wall"
                color: "black"
                mask: Region {}
                TransitionView {
                    id: tv; anchors.fill: parent; line: root.nextPal[1]
                    onOutlineDone: root.pal = root.nextPal
                    onFinished: root.pal = root.nextPal
                    Connections {
                        target: root
                        function onChange(url, edges, info) {
                            if (info.instant || tv.current.toString() === "") { tv.current = url; return }
                            tv.go(url, edges, info);
                            if (info.mode === "colonies") root.pal = root.nextPal;
                        }
                    }
                }
            }
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-outline-bar"
                BarView { anchors.fill: parent; sys: live; pal: root.pal; onAct: (w, a) => root.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { nextWall.running = true } }
    IpcHandler { target: "wallpaper"; function next(): void { nextWall.running = true } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
