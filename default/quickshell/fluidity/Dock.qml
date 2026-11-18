pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// The Fluid dock's data: pinned apps (~/.config/fluidity/dock, "class command" per line) then running ones.
// Keys come through the island's "dockkeys" view, which holds the keyboard while the dock is lit.
Singleton {
    id: dock
    property int sel: -1
    readonly property bool shown: Theme.name === "fluid" && Widgets.shown.includes("dock") && Island.barShown
    readonly property var defaults: [["calendio", "calendio"], ["zen", "zen-browser"], ["com.mitchellh.ghostty", "ghostty"], ["obsidian", "obsidian"],
                                     ["spotify", "spotify"], ["vesktop", "vesktop"], ["burrow", "burrow"], ["code-insiders", "code-insiders"]]
    property var pinned: defaults
    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/fluidity/dock"
        watchChanges: true; onFileChanged: reload()
        onLoaded: { const l = text().split("\n").map(x => x.trim()).filter(x => x && !x.startsWith("#")).map(x => { const i = x.indexOf(" "); return i < 0 ? [x, x] : [x.slice(0, i), x.slice(i + 1)] }); dock.pinned = l.length ? l : dock.defaults }
        onLoadFailed: dock.pinned = dock.defaults
    }
    function entryFor(cls) {
        const id = String(cls).toLowerCase(), short = id.replace(/^.*\./, "");
        return DesktopEntries.byId(cls) ?? DesktopEntries.byId(short) ?? DesktopEntries.applications.values.find(e => (e.id || "").toLowerCase().replace(/\.desktop$/, "") === short || String(e.startupClass || "").toLowerCase() === id) ?? null;
    }
    readonly property var items: {
        const wins = Hyprland.toplevels.values, active = Hyprland.activeToplevel?.lastIpcObject?.class || "";
        const classes = wins.map(t => t.lastIpcObject?.class || "").filter(Boolean);
        const out = pinned.map(p => ({ cls: p[0], cmd: p[1] }));
        for (const c of classes) if (!out.some(o => o.cls.toLowerCase() === c.toLowerCase())) out.push({ cls: c, cmd: "" });
        return out.map(o => {
            const e = entryFor(o.cls), running = classes.some(c => c.toLowerCase() === o.cls.toLowerCase());
            return { cls: o.cls, cmd: o.cmd || (e ? "gtk-launch " + e.id.replace(/\.desktop$/, "") : ""), title: e ? e.name : o.cls.replace(/^.*\./, ""),
                     image: e && e.icon ? Quickshell.iconPath(e.icon, true) : "", glyph: Island.glyphFor(o.cls), running: running, focused: running && active.toLowerCase() === o.cls.toLowerCase() };
        });
    }
    function launch(i) {
        const it = items[i];
        if (!it) return;
        Island.sh("fluidity-launch focus " + Island.q(it.cls) + " " + (it.cmd || Island.q(it.cls)));
    }
    function key(event) {
        const k = event.key, n = items.length;
        if (k === Qt.Key_Escape) { Island.close(); return true; }
        if (k === Qt.Key_Left || k === Qt.Key_Backtab) sel = Math.max(0, sel - 1);
        else if (k === Qt.Key_Right || k === Qt.Key_Tab) sel = Math.min(n - 1, sel + 1);
        else if (k === Qt.Key_Home) sel = 0;
        else if (k === Qt.Key_End) sel = n - 1;
        else if (k === Qt.Key_Return || k === Qt.Key_Enter) { const i = sel; Island.close(); Island.later(200, () => dock.launch(i)); }
        else if (event.text >= "1" && event.text <= "9") { const i = Number(event.text) - 1; Island.close(); Island.later(200, () => dock.launch(i)); }
        return true;
    }
}
