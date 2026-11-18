pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The current theme's colours (~/.config/fluidity/theme/colors.toml), live. `pal` is what every view takes.
Singleton {
    id: theme
    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", blue: "#a9b8e8", red: "#f2a7a7", fg: "#e3e4da", dim: "#878880",
                         muted: "#3a3f45", bg: "#111417", yellow: "#e8d98a", magenta: "#c8a8e0", orange: "#f0c08a" })
    readonly property var keys: ({ accent: "accent", cyan: "cyan", blue: "blue", red: "red", foreground: "fg",
        dark_foreground: "dim", muted: "muted", background: "background", yellow: "yellow", magenta: "magenta", orange: "orange" })

    function parse(text) {
        const p = Object.assign({}, pal);
        for (const line of String(text).split("\n")) {
            const m = line.match(/^\s*([a-z_]+)\s*=\s*"(#[0-9a-fA-F]{6})"/);
            if (m && keys[m[1]]) p[keys[m[1]] === "background" ? "bg" : keys[m[1]]] = m[2];
        }
        pal = p;
    }

    property string name: ""   // the theme's folder name (fluid, ...)
    Process { id: nameProc; command: ["readlink", "-f", Quickshell.env("HOME") + "/.config/fluidity/theme"]
        stdout: StdioCollector { onStreamFinished: theme.name = String(text).trim().split("/").pop() } }
    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/fluidity/theme/colors.toml"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { theme.parse(text()); nameProc.running = true }
    }
    IpcHandler {
        target: "theme"
        function reload(): void { file.reload() }
    }
}
