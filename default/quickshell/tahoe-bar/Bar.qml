import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// macOS Tahoe menu bar: an exact copy, no Lyric styling. MenuBarView.qml draws it, MacMenu.qml
// shows the menus (the dock shares it) and MacDialogs.qml holds the Apple menu's windows:
// About This Mac, Force Quit Applications and the Restart / Shut Down / Log Out alert.
//
// Linux apps don't export their menus, so every app gets the standard Mac set (File, Edit,
// View, Window, Help) wired to real actions: Hyprland dispatches for windows, wtype for the
// shortcuts behind Edit and View. The desktop and Nautilus are "Finder", with Finder's Go menu.
// Pre-Tahoe bar: ~/claude/archy-cleanup/before-tahoe-2026-11-05 (restore.sh switches back).
//
// Extra status items (AI usage robot, CPU, weather, custom commands…) come from
// ~/.local/state/fluidity/menubar.json, which System Settings > Menu Bar edits (lyric-settings-data);
// their values come from fluidity-menubar-status and AiUsage.qml.
PanelWindow {
    id: bar

    required property ShellScreen modelData
    screen: modelData

    // Keyboard mode (Luminescent) has its own bar, so the Tahoe menu bar steps aside.
    visible: Theme.mode !== "keyboard"

    anchors { top: true; left: true; right: true }
    implicitHeight: 24
    color: "transparent"
    // Not qs-lyric-*: Tahoe's bar is clear, so Hyprland must not blur it. looknfeel.lua blurs
    // only this layer's popups (the menus).
    WlrLayershell.namespace: "qs-menubar"
    WlrLayershell.layer: WlrLayer.Top

    SystemClock { id: clock; precision: bar.clockCfg.seconds || (bar.status.toolkit?.focus?.until ?? 0) > 0 ? SystemClock.Seconds : SystemClock.Minutes }
    readonly property var clockCfg: Object.assign({ weekday: true, date: true, h24: false, seconds: false }, cfg.clock ?? {})
    readonly property string clockFormat: [clockCfg.weekday ? "ddd" : "", clockCfg.date ? "MMM d" : ""]
        .filter(x => x).join(" ") + "  " + (clockCfg.h24 ? "HH:mm" : "h:mm") + (clockCfg.seconds ? ":ss" : "")
        + (clockCfg.h24 ? "" : " AP")

    // ---- focused app -------------------------------------------------------------------

    readonly property var active: {
        const t = Hyprland.activeToplevel;
        const ws = Hyprland.focusedWorkspace;
        return t && ws && t.workspace && t.workspace.id === ws.id ? t : null;
    }
    function appIdOf(t) { return t?.wayland?.appId ?? t?.lastIpcObject?.class ?? "" }
    function keyOf(t) {
        const id = appIdOf(t);
        return DesktopEntries.heuristicLookup(id)?.id ?? id;
    }
    readonly property string appKey: active ? keyOf(active) : ""
    readonly property var entry: appKey ? (DesktopEntries.byId(appKey) ?? DesktopEntries.heuristicLookup(appKey)) : null
    // Burrow (~/claude/burrow) is the Finder copy; it gets Finder's own menus
    // (spec/reference/tahoe-1x/menus.json), sent as Burrow's shortcuts.
    readonly property bool burrow: /^burrow/i.test(appKey)
    readonly property bool finder: !active || appKey === "org.gnome.Nautilus" || burrow
    readonly property string appName: finder ? "Finder" : (entry?.name ?? appKey)
    readonly property bool terminal: /ghostty|kitty|foot|alacritty|wezterm|konsole|terminal/i.test(appKey)
    readonly property string userName: {
        const u = Quickshell.env("USER") ?? "";
        return u.charAt(0).toUpperCase() + u.slice(1);
    }

    readonly property var titles: ["", appName].concat(finder
        ? ["File", "Edit", "View", "Go", "Window", "Help"]
        : ["File", "Edit", "View", "Window", "Help"])

    // ---- actions -----------------------------------------------------------------------

    function run(cmd) { Quickshell.execDetached(cmd) }
    function addr(t) {
        const a = String(t.address);
        return a.startsWith("0x") ? a : "0x" + a;
    }
    function dispatch(s) { Hyprland.dispatch(s) }
    function windowsOf(key) { return Hyprland.toplevels.values.filter(t => keyOf(t) === key) }
    function hidden(t) { return (t.workspace?.name ?? "").startsWith("special:") }
    function show(t) {
        const ws = Hyprland.focusedWorkspace?.name ?? "1";
        dispatch(`hl.dsp.window.move({ workspace = "${ws}", window = "address:${addr(t)}", follow = false })`);
    }
    function focus(t) {
        if (hidden(t)) show(t);
        dispatch(`hl.dsp.focus({ window = "address:${addr(t)}" })`);
    }
    function openFinder(where) { run(["nautilus", "--new-window"].concat(where ? [where] : [])) }
    function home(p) { return Quickshell.env("HOME") + (p ? "/" + p : "") }

    // Sends an app shortcut once the menu has closed and the app has its keyboard focus back.
    // Terminals take Ctrl+Shift for the clipboard (plain Ctrl+C would interrupt the program).
    function keys(mods, key) {
        const m = terminal && ["c", "v", "a"].includes(key) ? mods.concat(["shift"]) : mods;
        const args = ["wtype"];
        for (const x of m) args.push("-M", x);
        args.push("-k", key);
        for (const x of m.slice().reverse()) args.push("-m", x);
        run(["sh", "-c", 'sleep 0.15; exec "$@"', "sh"].concat(args));
    }
    function icon(name) { return Quickshell.iconPath(name + "-symbolic", true) }
    readonly property var sep: ({ separator: true })

    // ---- menus -------------------------------------------------------------------------

    function appleMenu() {
        const launcherMenu = () => run(["fluidity-island", "launcher"]);
        return [
            { text: "About This Mac", action: () => Panels.toggle("about") },
            sep,
            { text: "System Settings…", action: () => run(["lyric-settings"]) },
            { text: "App Store", action: launcherMenu },
            sep,
            { text: "Force Quit…", shortcut: "⌥⌘⎋", action: () => Panels.toggle("forcequit") },
            sep,
            { text: "Sleep", action: () => run(["systemctl", "suspend"]) },
            { text: "Restart…", action: () => Panels.toggle("restart") },
            { text: "Shut Down…", action: () => Panels.toggle("shutdown") },
            sep,
            { text: "Lock Screen", shortcut: "⌃⌘Q", action: () => run(["loginctl", "lock-session"]) },
            { text: `Log Out ${userName}…`, shortcut: "⇧⌘Q", action: () => Panels.toggle("logout") }
        ];
    }

    function appMenu() {
        const key = appKey;
        const mine = windowsOf(key);
        const anyHidden = Hyprland.toplevels.values.some(hidden);
        const out = [
            { text: `About ${appName}`, enabled: false },
            sep,
            { text: "Settings…", shortcut: "⌘,", enabled: !!active, action: () => keys(["ctrl"], "comma") },
            sep
        ];
        if (finder)
            out.push({ text: "Empty Trash…", shortcut: "⇧⌘⌫", action: () => run(["gio", "trash", "--empty"]) }, sep);
        out.push(
            { text: "Show All", enabled: anyHidden, action: () => Hyprland.toplevels.values.filter(hidden).forEach(show) }
        );
        if (!finder)
            out.push(sep, { text: `Quit ${appName}`, shortcut: "⌘Q", enabled: mine.length > 0,
                            action: () => mine.forEach(t => t.wayland?.close()) });
        return out;
    }

    function fileMenu() {
        const win = !!active;
        if (finder)
            return [
                { text: "New Finder Window", shortcut: "⌘N", icon: icon("window-new"), action: () => openFinder("") },
                { text: "New Folder", shortcut: "⇧⌘N", icon: icon("folder-new"), enabled: win, action: () => keys(["ctrl", "shift"], "n") },
                { text: "New Tab", shortcut: "⌘T", icon: icon("tab-new"), enabled: win, action: () => keys(["ctrl"], "t") },
                sep,
                { text: "Close Window", shortcut: "⌘W", icon: icon("window-close"), enabled: win, action: () => dispatch("hl.dsp.window.close()") },
                sep,
                { text: "Find", shortcut: "⌘F", icon: icon("system-search"), action: () => Panels.toggle("spotlight") }
            ];
        return [
            { text: "New Window", shortcut: "⌘N", icon: icon("window-new"), action: () => entry?.execute() },
            { text: "New Tab", shortcut: "⌘T", icon: icon("tab-new"), enabled: win, action: () => keys(["ctrl"], "t") },
            { text: "Open…", shortcut: "⌘O", icon: icon("document-open"), enabled: win && !terminal, action: () => keys(["ctrl"], "o") },
            sep,
            { text: "Close Window", shortcut: "⌘W", icon: icon("window-close"), enabled: win, action: () => dispatch("hl.dsp.window.close()") },
            { text: "Save", shortcut: "⌘S", icon: icon("document-save"), enabled: win && !terminal, action: () => keys(["ctrl"], "s") },
            sep,
            { text: "Print…", shortcut: "⌘P", icon: icon("document-print"), enabled: win && !terminal, action: () => keys(["ctrl"], "p") }
        ];
    }

    function editMenu() {
        const win = !!active;
        return [
            { text: "Undo", shortcut: "⌘Z", icon: icon("edit-undo"), enabled: win && !terminal, action: () => keys(["ctrl"], "z") },
            { text: "Redo", shortcut: "⇧⌘Z", icon: icon("edit-redo"), enabled: win && !terminal, action: () => keys(["ctrl", "shift"], "z") },
            sep,
            { text: "Cut", shortcut: "⌘X", icon: icon("edit-cut"), enabled: win && !terminal, action: () => keys(["ctrl"], "x") },
            { text: "Copy", shortcut: "⌘C", icon: icon("edit-copy"), enabled: win, action: () => keys(["ctrl"], "c") },
            { text: "Paste", shortcut: "⌘V", icon: icon("edit-paste"), enabled: win, action: () => keys(["ctrl"], "v") },
            { text: "Select All", shortcut: "⌘A", icon: icon("edit-select-all"), enabled: win, action: () => keys(["ctrl"], "a") }
        ];
    }

    function viewMenu() {
        const win = !!active;
        const full = (active?.lastIpcObject?.fullscreen ?? 0) > 0;
        const out = [];
        if (finder)
            out.push(
                { text: "as Icons", shortcut: "⌘1", icon: icon("view-grid"), enabled: win, action: () => keys(["ctrl"], "2") },
                { text: "as List", shortcut: "⌘2", icon: icon("view-list"), enabled: win, action: () => keys(["ctrl"], "1") },
                sep
            );
        else
            out.push(
                { text: "Actual Size", shortcut: "⌘0", icon: icon("zoom-original"), enabled: win, action: () => keys(["ctrl"], "0") },
                { text: "Zoom In", shortcut: "⌘+", icon: icon("zoom-in"), enabled: win, action: () => keys(["ctrl"], "equal") },
                { text: "Zoom Out", shortcut: "⌘-", icon: icon("zoom-out"), enabled: win, action: () => keys(["ctrl"], "minus") },
                sep
            );
        out.push({ text: full ? "Exit Full Screen" : "Enter Full Screen", shortcut: "⌃⌘F", icon: icon("view-fullscreen"),
                   enabled: win, action: () => dispatch('hl.dsp.window.fullscreen({ mode = "fullscreen" })') });
        return out;
    }

    function goMenu() {
        const nav = finder && !!active;
        const place = (text, shortcut, iconName, where) => ({ text, shortcut, icon: icon(iconName), action: () => openFinder(where) });
        return [
            { text: "Back", shortcut: "⌘[", icon: icon("go-previous"), enabled: nav, action: () => keys(["alt"], "Left") },
            { text: "Forward", shortcut: "⌘]", icon: icon("go-next"), enabled: nav, action: () => keys(["alt"], "Right") },
            { text: "Enclosing Folder", shortcut: "⌘↑", icon: icon("go-up"), enabled: nav, action: () => keys(["alt"], "Up") },
            sep,
            place("Recents", "⇧⌘F", "document-open-recent", "recent:///"),
            place("Documents", "⇧⌘O", "folder-documents", home("Documents")),
            place("Desktop", "⇧⌘D", "user-desktop", home("Desktop")),
            place("Downloads", "⌥⌘L", "folder-download", home("Downloads")),
            place("Home", "⇧⌘H", "user-home", home("")),
            place("Computer", "⇧⌘C", "computer", "/"),
            place("Network", "⇧⌘K", "network-workgroup", "network:///"),
            place("Applications", "⇧⌘A", "folder", "/usr/share/applications"),
            sep,
            { text: "Go to Folder…", shortcut: "⇧⌘G", icon: icon("folder-open"),
              action: () => nav ? keys(["ctrl"], "l") : openFinder("") }
        ];
    }

    function windowMenu() {
        const win = !!active;
        const floating = active?.lastIpcObject?.floating === true;
        const out = [
            { text: "Zoom", icon: icon("window-maximize"), enabled: win,
              action: () => dispatch('hl.dsp.window.fullscreen({ mode = "maximized" })') },
            { text: "Center", icon: icon("zoom-fit-best"), enabled: win && floating, action: () => dispatch("hl.dsp.window.center()") },
            sep,
            { text: "Bring All to Front", enabled: win, action: () => windowsOf(appKey).forEach(focus) }
        ];
        const mine = active ? windowsOf(appKey) : [];
        if (mine.length) out.push(sep);
        for (const t of mine)
            out.push({ text: t.title || appName, checked: t === active, action: () => focus(t) });
        return out;
    }

    // ---- Burrow: Finder's menus, each item sending Burrow's chord ----------------------

    function bk(mods, key) { return () => keys(mods, key) }

    // Burrow's focused window writes its state here (selection, view, paste,
    // undo), so these menus can tick and grey items like Finder's.
    property var bs: ({})
    readonly property bool bsel: (bs.selected ?? 0) > 0
    FileView {
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/burrow-menu.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { bar.bs = JSON.parse(text()); } catch (e) {} }
        onLoadFailed: bar.bs = ({})
    }
    function off(text, shortcut) { return { text, shortcut, enabled: false } }

    function burrowFileMenu() {
        return [
            { text: "New Finder Window", shortcut: "⌘N", icon: icon("window-new"), action: () => run(["burrow"]) },
            { text: "New Folder", shortcut: "⇧⌘N", icon: icon("folder-new"), action: bk(["ctrl", "shift"], "n") },
            off("New Smart Folder"),
            { text: "New Tab", shortcut: "⌘T", icon: icon("tab-new"), action: bk(["ctrl"], "t") },
            { text: "Open", shortcut: "⌘O", enabled: bsel, action: bk(["ctrl"], "o") },
            { text: "Close Window", shortcut: "⌘W", icon: icon("window-close"), action: bk(["ctrl"], "w") },
            sep,
            { text: "Get Info", shortcut: "⌘I", icon: icon("dialog-information"), action: bk(["ctrl"], "i") },
            { text: "Duplicate", shortcut: "⌘D", enabled: bsel, action: bk(["ctrl"], "d") },
            { text: "Make Alias", shortcut: "⌃⌘A", enabled: bsel, action: bk(["ctrl", "logo"], "a") },
            { text: "Quick Look", shortcut: "⌘Y", enabled: bsel, action: bk([], "space") },
            off("Print", "⌘P"),
            sep,
            off("Show Original", "⌘R"),
            { text: "Add to Sidebar", shortcut: "⌃⌘T", enabled: (bs.selected ?? 0) === 1, action: bk(["ctrl", "logo"], "t") },
            sep,
            { text: "Move to Trash", shortcut: "⌘⌫", icon: icon("user-trash"), enabled: bsel, action: bk(["ctrl"], "BackSpace") },
            off("Eject", "⌘E"),
            sep,
            { text: "Find", shortcut: "⌘F", icon: icon("system-search"), action: bk(["ctrl"], "f") },
            sep,
            { text: "Tags…", enabled: bsel, action: bk(["ctrl", "alt", "shift"], "t") }
        ];
    }

    function burrowEditMenu() {
        return [
            { text: "Undo", shortcut: "⌘Z", icon: icon("edit-undo"), enabled: bs.canUndo !== false, action: bk(["ctrl"], "z") },
            { text: "Redo", shortcut: "⇧⌘Z", icon: icon("edit-redo"), enabled: bs.canRedo !== false, action: bk(["ctrl", "shift"], "z") },
            sep,
            { text: "Cut", shortcut: "⌘X", icon: icon("edit-cut"), enabled: bsel, action: bk(["ctrl"], "x") },
            { text: "Copy", shortcut: "⌘C", icon: icon("edit-copy"), enabled: bsel, action: bk(["ctrl"], "c") },
            { text: "Copy as Pathname", shortcut: "⌥⌘C", enabled: bsel, action: bk(["ctrl", "alt"], "c") },
            { text: "Paste", shortcut: "⌘V", icon: icon("edit-paste"), enabled: bs.canPaste !== false, action: bk(["ctrl"], "v") },
            { text: "Move Item Here", shortcut: "⌥⌘V", enabled: bs.canPaste !== false, action: bk(["ctrl", "alt"], "v") },
            { text: "Select All", shortcut: "⌘A", icon: icon("edit-select-all"), action: bk(["ctrl"], "a") },
            sep,
            off("Show Clipboard")
        ];
    }

    function burrowViewMenu() {
        const full = (active?.lastIpcObject?.fullscreen ?? 0) > 0;
        return [
            { text: "as Icons", shortcut: "⌘1", icon: icon("view-grid"), checked: bs.view === "icons", action: bk(["ctrl"], "1") },
            { text: "as List", shortcut: "⌘2", icon: icon("view-list"), checked: bs.view === "list", action: bk(["ctrl"], "2") },
            { text: "as Columns", shortcut: "⌘3", checked: bs.view === "columns", action: bk(["ctrl"], "3") },
            { text: "as Gallery", shortcut: "⌘4", checked: bs.view === "gallery", action: bk(["ctrl"], "4") },
            sep,
            { text: "Use Groups", shortcut: "⌃⌘0", checked: bs.groups === true, action: bk(["ctrl", "logo"], "0") },
            sep,
            { text: bs.pathBar ? "Hide Path Bar" : "Show Path Bar", shortcut: "⌥⌘P", action: bk(["ctrl", "alt"], "p") },
            { text: bs.statusBar ? "Hide Status Bar" : "Show Status Bar", shortcut: "⌘/", action: bk(["ctrl"], "slash") },
            sep,
            { text: "Show View Options", shortcut: "⌘J", action: bk(["ctrl"], "j") },
            sep,
            { text: full ? "Exit Full Screen" : "Enter Full Screen", shortcut: "⌃⌘F", icon: icon("view-fullscreen"),
              action: () => dispatch('hl.dsp.window.fullscreen({ mode = "fullscreen" })') }
        ];
    }

    function burrowGoMenu() {
        const place = (text, shortcut, iconName, mods, key) => ({ text, shortcut, icon: icon(iconName), action: bk(mods, key) });
        return [
            { text: "Back", shortcut: "⌘[", icon: icon("go-previous"), enabled: bs.canGoBack !== false, action: bk(["ctrl"], "bracketleft") },
            { text: "Forward", shortcut: "⌘]", icon: icon("go-next"), enabled: bs.canGoForward !== false, action: bk(["ctrl"], "bracketright") },
            { text: "Enclosing Folder", shortcut: "⌘↑", icon: icon("go-up"), action: bk(["ctrl"], "Up") },
            sep,
            place("Recents", "⇧⌘F", "document-open-recent", ["ctrl", "shift"], "f"),
            place("Documents", "⇧⌘O", "folder-documents", ["ctrl", "shift"], "o"),
            place("Desktop", "⇧⌘D", "user-desktop", ["ctrl", "shift"], "d"),
            place("Downloads", "⌥⌘L", "folder-download", ["ctrl", "alt"], "l"),
            place("Home", "⇧⌘H", "user-home", ["ctrl", "shift"], "h"),
            place("Computer", "⇧⌘C", "computer", ["ctrl", "shift"], "c"),
            place("Applications", "⇧⌘A", "folder", ["ctrl", "shift"], "a"),
            sep,
            { text: "Go to Folder…", shortcut: "⇧⌘G", icon: icon("folder-open"), action: bk(["ctrl", "shift"], "g") },
            { text: "Connect to Server…", shortcut: "⌘K", icon: icon("network-server"), action: bk(["ctrl"], "k") }
        ];
    }

    function entriesFor(i) {
        if (i === 0) return appleMenu();
        if (i === 1) return appMenu();
        if (burrow)
            switch (titles[i]) {
            case "File": return burrowFileMenu();
            case "Edit": return burrowEditMenu();
            case "View": return burrowViewMenu();
            case "Go": return burrowGoMenu();
            }
        switch (titles[i]) {
        case "File": return fileMenu();
        case "Edit": return editMenu();
        case "View": return viewMenu();
        case "Go": return goMenu();
        case "Window": return windowMenu();
        default: return [{ text: `${appName} Help`, enabled: false }];
        }
    }

    // ---- extra status items ------------------------------------------------------------

    property var cfg: ({ items: [{ id: "ai", shown: true }] })
    readonly property var shownItems: (cfg.items ?? []).filter(i => i && i.shown !== false)
    function hasItem(id) { return shownItems.some(i => i.id === id) }

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/fluidity/menubar.json"
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { bar.cfg = JSON.parse(text()); } catch (e) {}
        }
        onLoadFailed: bar.cfg = ({ items: [{ id: "ai", shown: true }] })
    }

    // Latest fluidity-menubar-status output per item id.
    property var status: ({})
    function setStatus(id, value) {
        const s = Object.assign({}, status);
        s[id] = value;
        status = s;
    }

    Binding { target: AiUsage; property: "wanted"; value: bar.hasItem("ai") }

    // What to poll, and how often: [{ id, cmd, every (ms) }].
    readonly property var pollSpecs: {
        const w = cfg.weather ?? {};
        const out = [];
        for (const it of shownItems) {
            if (it.id === "cpu") out.push({ id: it.id, cmd: ["fluidity-menubar-status", "cpu"], every: 3000 });
            else if (it.id === "memory") out.push({ id: it.id, cmd: ["fluidity-menubar-status", "memory"], every: 5000 });
            else if (it.id === "vpn") out.push({ id: it.id, cmd: ["fluidity-menubar-status", "vpn"], every: 10000 });
            else if (it.id === "toolkit") out.push({ id: it.id, cmd: ["lyric-toolkit", "get", "toolkit"], every: 15000 });
            else if (it.id === "weather")
                out.push({ id: it.id, cmd: ["fluidity-menubar-status", "weather", w.units === "f" ? "f" : "c", w.place ?? ""], every: 300000 });
            else if (it.custom && it.poll)
                out.push({ id: it.id, cmd: ["fluidity-menubar-status", "custom", it.poll], every: Math.max(2, it.interval ?? 60) * 1000 });
        }
        return out;
    }

    Variants {
        model: bar.pollSpecs
        Scope {
            id: poller
            required property var modelData
            function poll() { if (!proc.running) proc.running = true }
            Process {
                id: proc
                command: poller.modelData.cmd
                stdout: StdioCollector {
                    onStreamFinished: {
                        try { bar.setStatus(poller.modelData.id, JSON.parse(text)); } catch (e) {}
                    }
                }
            }
            Timer {
                interval: poller.modelData.every; running: true; repeat: true; triggeredOnStart: true
                onTriggered: poller.poll()
            }
        }
    }

    Timer {   // Stay Awake can also change from the control center or the launcher.
        interval: 10000; running: bar.hasItem("caffeine"); repeat: true; triggeredOnStart: true
        onTriggered: SystemState.refresh()
    }

    // White copies of WhiteSur glyphs (make_menubar_icons.py): Qt draws the theme's currentColor black.
    function mbIcon(name) { return Qt.resolvedUrl("menubar-icons/" + name + ".svg") }
    function levelColor(p) { return p >= 85 ? "#ff453a" : p >= 60 ? "#ffd60a" : "#30d158" }
    function short(t, n) { return t.length > n ? t.slice(0, n - 1) + "…" : t }

    readonly property var extras: {
        const out = [];
        for (const it of shownItems) {
            const st = status[it.id] ?? null;
            switch (it.id) {
            case "ai": {
                const w = AiUsage.worst;
                out.push({ id: "ai", glyph: "robot", eye: w === null ? "white" : levelColor(w),
                           text: cfg.ai?.percent && w !== null ? `${w}%` : "" });
                break;
            }
            case "cpu": out.push({ id: "cpu", icon: mbIcon("cpu"), text: st?.text ?? "" }); break;
            case "memory": out.push({ id: "memory", icon: mbIcon("computer-chip"), text: st?.text ?? "" }); break;
            case "weather": out.push({ id: "weather", icon: mbIcon("weather-few-clouds"), text: st?.text ?? "" }); break;
            case "vpn": if (st?.active) out.push({ id: "vpn", icon: mbIcon("network-vpn") }); break;
            case "caffeine": out.push({ id: "caffeine", icon: mbIcon("display-brightness"), dim: !SystemState.caffeine }); break;
            case "toolkit": {   // a running Focus session counts down next to the icon
                const f = status.toolkit?.focus;
                out.push({ id: "toolkit", icon: mbIcon("applications-utilities"),
                           text: f && f.until * 1000 > clock.date.getTime() ? focusLeft(f) : "" });
                break;
            }
            case "nowplaying": {
                const p = Media.player;
                if (p) out.push({ id: "nowplaying", icon: mbIcon(p.isPlaying ? "media-playback-start" : "media-playback-pause"),
                                  text: short(p.trackTitle || p.identity || "", 24) });
                break;
            }
            default:
                if (it.custom)
                    out.push({ id: it.id, icon: mbIcon(it.icon || "system-run"), text: it.poll ? short(st?.text ?? "", 24) : "" });
            }
        }
        return out;
    }

    function countdown(ts) {
        const s = (ts ?? 0) - Date.now() / 1000;
        if (!ts || s <= 0) return "now";
        const d = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
        return d ? `${d}d ${h}h` : h ? `${h}h ${m}m` : `${m}m`;
    }
    function rowsOf(st) { return (st?.rows ?? []).map(r => ({ text: r.text, detail: r.detail, inert: true })) }
    function openUrl(u) { run(["xdg-open", u]) }
    readonly property var settingsEntry: ({ text: "Menu Bar Settings…", action: () => run(["lyric-settings", "menubar"]) })

    function aiMenu() {
        const d = AiUsage.data;
        const out = [];
        for (const [key, name] of [["claude", "Claude"], ["codex", "Codex"]]) {
            const p = d?.[key];
            out.push({ text: name + (p?.stale ? "  (last known)" : ""), enabled: false });
            if (!p) { out.push({ text: "No data yet", inert: true }, sep); continue; }
            const limit = (label, pct, resets) => ({ text: label, meter: pct ?? 0, meterColor: levelColor(pct ?? 0), inert: true,
                                                     detail: `${pct ?? 0}%  ·  resets in ${countdown(resets)}` });
            out.push(limit("Session (5 hours)", p.session, p.sessionResets), limit("Weekly (7 days)", p.week, p.weekResets), sep);
        }
        out.push({ text: "Refresh Now", action: () => AiUsage.refresh(true) },
                 { text: "Open Claude Usage…", action: () => openUrl("https://claude.ai/settings/usage") },
                 { text: "Open Codex Usage…", action: () => openUrl("https://chatgpt.com/codex/settings/usage") },
                 sep, settingsEntry);
        return out;
    }

    // Toolkit item (System Settings > Toolkit, ~/claude/archy-cleanup/toolkit): the tools that are on.
    function keyGlyphs(k) {
        if (!k) return "";
        const t = k.split("+").map(x => x.trim().toUpperCase());
        const g = { CTRL: "⌃", ALT: "⌥", SHIFT: "⇧", SUPER: "⌘" };
        return ["CTRL", "ALT", "SHIFT", "SUPER"].filter(m => t.includes(m)).map(m => g[m]).join("")
             + t.filter(x => !g[x]).map(x => x === "TAB" ? "⇥" : x === "SPACE" ? "Space" : x).join("");
    }
    function focusLeft(f) {
        const s = Math.max(0, Math.round((f?.until ?? 0) - clock.date.getTime() / 1000));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }
    function toolkitMenu() {
        const st = status.toolkit ?? null;
        const on = {};
        for (const t of st?.tools ?? []) if (t.enabled && t.ready) on[t.id] = t;
        const q = st?.quick ?? {};
        const tk = (...a) => () => run(["lyric-toolkit", "run"].concat(a));
        const pane = p => () => run(["lyric-settings", p]);
        const out = [];
        const add = (id, e) => { if (on[id]) out.push(Object.assign({ shortcut: keyGlyphs(on[id].key) }, e)) };
        if (on.toggles) out.push({ text: "Quick Toggles", submenu: [
            { text: "Dark Mode", checked: !!q.dark, action: tk("toggles", "dark") },
            { text: "Show Hidden Files", checked: !!q.hidden, action: tk("toggles", "hidden") },
            { text: "Mute Microphone", checked: !!q.micMuted, action: tk("toggles", "mic") },
            sep,
            { text: "Empty Trash", action: tk("toggles", "trash") },
            { text: "Eject All", action: tk("toggles", "eject") },
            sep,
            { text: "Open Quick Panel", shortcut: keyGlyphs(on.toggles.key), action: tk("toggles", "panel") }] });
        if (on.focus) {
            const f = st?.focus ?? null;
            out.push(f?.running ? { text: "Stop Focus", detail: focusLeft(f), action: tk("focus") }
                                : { text: "Start Focus", submenu: [5, 15, 25, 45, 60, 90].map(m => (
                                      { text: m + " minutes", action: () => run(["lyric-toolkit", "set", "focus", "start", String(m)]) })) });
        }
        add("clipboard", { text: "Clipboard History…", action: tk("clipboard") });
        add("radial", { text: "Snap Window…", action: tk("radial") });
        add("colorpicker", { text: "Pick Colour", action: tk("colorpicker") });
        add("ocr", { text: "Copy Text from Screen", action: tk("ocr") });
        add("screenshot", { text: "Screenshot…", action: tk("screenshot") });
        add("scratchpad", { text: "Scratchpad", action: tk("scratchpad") });
        add("shelf", { text: "Drop Shelf", action: tk("shelf") });
        add("mixer", { text: "Volume Mixer…", action: tk("mixer") });
        add("awake", { text: "Keep Awake", action: tk("awake") });
        add("camera", { text: "Camera Preview", action: tk("camera") });
        add("cleaning", { text: "Cleaning Mode", action: tk("cleaning") });
        const panes = [["stats", "System Stats…"], ["cleaner", "Cleaner…"], ["packages", "Packages…"], ["uninstaller", "Uninstaller…"]]
            .filter(p => on[p[0]]).map(p => ({ text: p[1], action: pane(p[0]) }));
        if (panes.length) out.push(sep, ...panes);
        if (out.length) out.push(sep);
        out.push({ text: "Toolkit Settings…", action: pane("toolkit") });
        return out;
    }

    function extraMenu(id) {
        const st = status[id] ?? null;
        const monitor = { text: "Open Activity Monitor…", action: () => run(["ghostty", "-e", "btop"]) };
        switch (id) {
        case "ai": return aiMenu();
        case "toolkit": return toolkitMenu();
        case "cpu":
            return [{ text: `CPU Load  ${st?.text ?? "…"}`, meter: st?.value ?? 0, meterColor: levelColor(st?.value ?? 0), inert: true },
                    sep, { text: "Busiest Processes", enabled: false }].concat(rowsOf(st), [sep, monitor, settingsEntry]);
        case "memory":
            return [{ text: "Memory Used", detail: st?.text ?? "…", meter: st?.value ?? 0, meterColor: levelColor(st?.value ?? 0), inert: true },
                    { text: st?.summary ?? "", enabled: false },
                    sep, { text: "Largest Processes", enabled: false }].concat(rowsOf(st), [sep, monitor, settingsEntry]);
        case "weather": {
            const place = cfg.weather?.place ?? "";
            return rowsOf(st).concat([sep, { text: "Open Forecast…", action: () => openUrl("https://wttr.in/" + encodeURIComponent(place)) }, sep, settingsEntry]);
        }
        case "vpn":
            return rowsOf(st).concat([sep, { text: "Open Proton VPN…", action: () => run(["protonvpn-app"]) }, sep, settingsEntry]);
        case "caffeine":
            return [{ text: "Stay Awake", checked: SystemState.caffeine, action: () => SystemState.toggleCaffeine() },
                    { text: SystemState.caffeine ? "Idle lock and screen off are paused" : "Idle lock is on", enabled: false },
                    sep, { text: "Lock Screen Settings…", action: () => run(["lyric-settings", "lockscreen"]) }, settingsEntry];
        case "nowplaying": {
            const p = Media.player;
            if (!p) return [{ text: "Nothing playing", enabled: false }, sep, settingsEntry];
            return [{ text: p.trackTitle || "Unknown track", inert: true },
                    { text: [p.trackArtist, p.trackAlbum].filter(x => x).join(" — ") || p.identity, enabled: false },
                    sep,
                    { text: p.isPlaying ? "Pause" : "Play", enabled: p.canTogglePlaying, action: () => p.togglePlaying() },
                    { text: "Next", enabled: p.canGoNext, action: () => p.next() },
                    { text: "Previous", enabled: p.canGoPrevious, action: () => p.previous() },
                    sep, { text: `Show ${p.identity}`, enabled: p.canRaise, action: () => p.raise() }, settingsEntry];
        }
        default: {
            const it = shownItems.find(i => i.id === id);
            if (!it) return [settingsEntry];
            const out = [{ text: it.name, enabled: false }].concat(it.poll ? rowsOf(st) : []);
            out.push(sep);
            if (it.command) out.push({ text: `Run ${it.name}`, action: () => run(["sh", "-c", it.command]) });
            out.push(settingsEntry);
            return out;
        }
        }
    }

    function extraPressed(id, x, w) {
        if (menu.opened && openExtra === id) { menu.close(); return; }
        const it = shownItems.find(i => i.id === id);
        // A custom item that only runs something runs it straight away.
        if (it?.custom && !it.poll && it.command) { menu.close(); run(["sh", "-c", it.command]); return; }
        if (id === "ai") AiUsage.refresh(false);
        openIndex = -1;
        openExtra = id;
        menu.open(bar, x + 4, 28, extraMenu(id), false);
    }

    // ---- open menu ---------------------------------------------------------------------

    property int openIndex: -1
    property string openExtra: ""
    property string lastStatus: ""

    function openMenu(i) {
        if (i < 0 || i >= titles.length) return;
        Hyprland.refreshToplevels();
        openExtra = "";
        openIndex = i;
        // The menu's first column lines up under the title text; it floats 6 px under the capsule.
        menu.open(bar, Math.max(6, view.titleTextX(i) - 26), 28, entriesFor(i), false);
    }

    MacMenu {
        id: menu
        keepLive: [bar]
        onClosed: { bar.openIndex = -1; bar.openExtra = ""; }
        onSideways: step => {
            if (bar.openIndex >= 0) bar.openMenu((bar.openIndex + step + bar.titles.length) % bar.titles.length);
        }
    }

    MenuBarView {
        id: view
        anchors.fill: parent
        titles: bar.titles
        openIndex: bar.openIndex
        clockText: Qt.formatDateTime(clock.date, bar.clockFormat).trim()
        extras: bar.extras
        openExtra: bar.openExtra
        openStatus: Panels.open === "spotlight" ? "spotlight"
                  : Panels.open === "control" ? (bar.lastStatus === "clock" ? "clock" : "control") : ""

        onTitlePressed: i => {
            if (menu.opened && bar.openIndex === i) menu.close();
            else bar.openMenu(i);
        }
        onTitleEntered: i => {
            if (menu.opened && bar.openIndex !== i) bar.openMenu(i);
        }
        onExtraPressed: (id, x, w) => bar.extraPressed(id, x, w)
        onStatusPressed: name => {
            menu.close();
            bar.lastStatus = name;
            Panels.toggle(name === "spotlight" ? "spotlight" : "control");
        }
    }
}
