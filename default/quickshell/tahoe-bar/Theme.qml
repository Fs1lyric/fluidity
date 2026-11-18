pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Colours come from ~/.config/fluidity/theme/colors.toml and follow it live.
// The defaults below are the mono palette, used until the file loads.
Singleton {
    id: theme

    property color background: "#0a0a0a"
    property color surface: "#161616"
    property color selection: "#2a2a2a"
    property color muted: "#3a3a3a"
    property color foreground: "#e8e8e8"
    property color dim: "#8a8a8a"
    property color accent: "#ffffff"
    property color red: "#ff5555"
    property color green: "#f0f0f0"
    property color yellow: "#d0d0d0"
    property color blue: "#c4c4c4"
    property color magenta: "#ffffff"
    property color cyan: "#a8a8a8"
    property color slate: "#9a9a9a"

    // Glass: surfaces are see-through and Hyprland blurs what is behind them.
    readonly property real glass: 0.85
    readonly property real cardGlass: 0.92
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12
    readonly property int radius: 0

    // Shared panel look (launcher, control center, notifications, power menu).
    readonly property real panelGlass: 0.82
    readonly property real outline: 0.16
    readonly property real hint: 0.42

    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
    // Anurati (the Mond face) only has A-Z, so headings set in it go through this.
    function mond(s) { return (s ?? "").toUpperCase().replace(/[^A-Z ]/g, "").trim() }

    readonly property var keys: ({
        background: "background", lighter_background: "surface", selection: "selection",
        muted: "muted", foreground: "foreground", dark_foreground: "dim", accent: "accent",
        red: "red", green: "green", yellow: "yellow", blue: "blue", magenta: "magenta",
        cyan: "cyan", brown: "slate"
    })

    function parse(text) {
        for (const line of text.split("\n")) {
            const m = line.match(/^\s*([a-z_]+)\s*=\s*"(#[0-9a-fA-F]{6})"/);
            if (m && keys[m[1]]) theme[keys[m[1]]] = m[2];
        }
    }

    // "mac" (Tahoe dock + menu bar) or "keyboard" (Luminescent); from the theme's mode file.
    property string mode: "mac"

    FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.config/fluidity/theme/colors.toml"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: theme.parse(text())
    }

    FileView {
        id: modeFile
        path: Quickshell.env("HOME") + "/.config/fluidity/theme/mode"
        onLoaded: theme.mode = text().trim() || "mac"
        onLoadFailed: theme.mode = "mac"
    }

    // fluidity-theme swaps the ~/.config/fluidity/theme symlink, which file watchers miss, then calls this.
    IpcHandler {
        target: "theme"
        function reload(): void { colorsFile.reload(); modeFile.reload() }
        function current(): string { return theme.mode }
    }
}
