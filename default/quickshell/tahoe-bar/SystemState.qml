pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// State that lives outside Quickshell: stay-awake (lyric-shell caffeine),
// night light (hyprsunset) and DDC brightness (lyric-shell's cache file).
// Polled while the control center is open, and right after each toggle.
Singleton {
    id: sys

    property bool caffeine: false
    property bool nightlight: false
    property int brightness: 100

    function refresh() { caffeineCheck.running = true; nightCheck.running = true; brightnessFile.reload() }

    function toggleCaffeine() { run(["fluidity-toggle", "idle"]) }
    function toggleNightlight() { run(["fluidity-toggle", "nightlight"]) }
    function setBrightness(percent) {
        brightness = percent;
        Quickshell.execDetached(["fluidity-shell", "brightness", "set", String(percent)]);
    }

    function run(cmd) { runner.command = cmd; runner.running = true }
    Process { id: runner; onExited: sys.refresh() }

    Process {
        id: caffeineCheck
        command: ["sh", "-c", "fluidity-toggle status idle | cut -d\\  -f2"]
        stdout: StdioCollector { onStreamFinished: sys.caffeine = text.trim() === "on" }
    }
    Process {
        id: nightCheck
        command: ["sh", "-c", "pgrep -x hyprsunset >/dev/null && hyprctl hyprsunset temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = parseInt((text.match(/\d+/) ?? ["6500"])[0]);
                sys.nightlight = t < 6000;
            }
        }
    }
    FileView {
        id: brightnessFile
        path: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/fluidity-brightness"
        printErrors: false
        onLoaded: { const v = parseInt(text()); if (!isNaN(v)) sys.brightness = v; }
    }

    Timer { interval: 3000; repeat: true; triggeredOnStart: true; running: Panels.open === "control"; onTriggered: sys.refresh() }
    Component.onCompleted: refresh()
}
