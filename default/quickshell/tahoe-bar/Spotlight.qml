import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Spotlight, macOS 27 "Golden Gate": Super+Alt+Space (and the Copilot key), which call
// `launcher toggle apps`; Launcher.qml hands that to this panel. The look is SpotlightView.qml
// (and AskPanelView.qml for answers); this file finds things and runs them.
//
// Apps come from the desktop entries; calculator, files, web, clipboard and the "Ask Claude"
// row come from ~/.local/bin/fluidity-search. Typing "g ", "yt ", "gh " or "w " searches the web
// there, "c " lists the clipboard history. A question ("...?", "how do I ...") shows the
// question capsule: Return asks Claude in the answer window, Down (or the Show Results pill)
// shows the results. Keys, with Ctrl for Golden Gate's Cmd: Return opens, Ctrl+R shows a file
// in Files, Ctrl+B searches the web, Ctrl+1/2/4 (or Tab, or a chip) filter to Applications,
// Files or Clipboard, Escape clears the text, then the filter, then closes. Launch counts are
// shared with the launcher.
Scope {
    id: spot

    readonly property bool shown: Panels.open === "spotlight"
    readonly property ShellScreen targetScreen: Panels.screen ?? Quickshell.screens[0]
    property var counts: ({})
    property string filter: ""      // the active chip
    property var extRows: []        // fluidity-search rows ...
    property string extFor: ""      // ... and the text they answer
    property string extWanted: ""   // newest text waiting for an answer
    // What fluidity-search is asked: the Clipboard chip searches the history for the text.
    readonly property string wanted: filter === "Clipboard" ? "c " + view.text : view.text

    onShownChanged: if (shown) {
        filter = "";
        view.reset();
        Qt.callLater(() => view.focusInput());
    }
    onWantedChanged: queryEdited()

    PanelWindow {
        id: win

        screen: spot.targetScreen
        visible: spot.shown || view.opacity > 0
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusiveZone: -1
        WlrLayershell.namespace: "qs-lyric-spotlight"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: spot.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        MouseArea { anchors.fill: parent; onClicked: Panels.close() }

        SpotlightView {
            id: view
            x: Math.round((win.width - width) / 2)
            y: Math.round(win.height * 0.22)
            // Springs open from just under full size, like Spotlight; shrinks a touch on close.
            opacity: spot.shown ? 1 : 0
            scale: spot.shown ? 1 : 0.94
            transformOrigin: Item.Top
            Behavior on opacity { NumberAnimation { duration: spot.shown ? 160 : 120; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: spot.shown ? 300 : 120; easing.type: spot.shown ? Easing.OutBack : Easing.InCubic; easing.overshoot: 1.2 } }
            rows: spot.rows
            question: spot.isQuestion && spot.filter === ""
            chips: spot.chips
            filter: spot.filter
            pillIcon: spot.icon("system-file-manager", "org.gnome.Nautilus", "folder")
            onActivated: (index, reveal) => spot.activate(index, reveal)
            onAskRequested: spot.startAsk(view.text.trim())
            onWebRequested: spot.searchWeb()
            onFilterPicked: name => spot.filter = name
            onDismissed: Panels.close()
        }
    }

    // ---- fluidity-search: one run at a time; a run finishing starts the next if needed ------

    Process {
        id: searcher
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const out = JSON.parse(text);
                    spot.extRows = out.rows;
                    spot.extFor = out.query;
                } catch (e) {}
            }
        }
        onExited: Qt.callLater(() => { if (spot.extWanted !== spot.extFor) spot.runSearch() })
    }
    Timer { id: debounce; interval: 60; onTriggered: spot.runSearch() }
    function runSearch() {
        extWanted = wanted;
        if (searcher.running || extWanted.trim() === "") return;
        searcher.command = ["fluidity-search", "query", extWanted];
        searcher.running = true;
    }
    function queryEdited() {
        if (wanted.trim() === "") { debounce.stop(); extRows = []; extFor = extWanted = wanted; }
        else debounce.restart();
    }
    function prefixOf(t) {
        const m = t.match(/^\s*(g|yt|gh|w|c)\s/);   // Qt's JS has no String.trimStart
        return m ? m[1] : "";
    }
    // Keep in step with QUESTION_WORDS / looks_like_question() in fluidity-search.
    readonly property var questionWords: ["what", "how", "why", "who", "when", "where", "which", "whose",
        "can", "could", "should", "would", "will", "is", "are", "was", "were", "does", "do", "did",
        "explain", "tell", "describe", "summarize", "summarise", "compare", "define"]
    function looksLikeQuestion(t) {
        const words = t.trim().split(/\s+/).filter(w => w !== "");
        if (!words.length || prefixOf(t)) return false;
        if (/\?\s*$/.test(t)) return /[0-9A-Za-zÀ-￿]/.test(t);   // V4 has no \p{L}
        return words.length >= 2 && questionWords.includes(words[0].toLowerCase());
    }
    readonly property bool isQuestion: looksLikeQuestion(view.text)

    // While a newer search runs, keep the old file and clipboard rows that still match (and
    // the Ask Claude row while it is still a question), so the list doesn't blink on every
    // keystroke. Calculator and web rows wait for the answer.
    readonly property var extNow: {
        if (extFor === wanted) return extRows;
        const key = prefixOf(wanted);
        if (key !== prefixOf(extFor)) return [];
        const words = wanted.trim().toLowerCase().split(/\s+/).slice(key ? 1 : 0);
        return extRows.filter(r => r.kind === "ask" ? isQuestion
            : (r.kind === "file" || r.kind === "clip") && words.every(w => r.label.toLowerCase().includes(w)));
    }

    // ---- rows: one flat list, best first; chips are the categories in it ------------------

    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)
    function rank(text, q) {
        const t = (text ?? "").toLowerCase();
        if (t.startsWith(q)) return 100;
        if (t.split(/\s+/).some(w => w.startsWith(q))) return 70;
        if (t.includes(q)) return 50;
        return 0;
    }
    function appRows(q, limit) {
        if (q === "")   // the Applications chip with no text: every app, by name
            return apps.slice().sort((a, b) => a.name.localeCompare(b.name)).slice(0, limit).map(appRow);
        return apps.map(e => {
            const extra = [e.genericName, e.comment, ...(e.keywords ?? [])].join(" ");
            const s = Math.max(rank(e.name, q), rank(extra, q) > 0 ? 20 : 0);
            return { e, s: s ? s + Math.min(counts[e.id] ?? 0, 30) : 0 };
        }).filter(r => r.s > 0).sort((a, b) => (b.s - a.s) || a.e.name.localeCompare(b.e.name))
          .slice(0, limit).map(r => appRow(r.e));
    }
    function appRow(e) {
        return { kind: "app", app: e, label: e.name, title: e.name, subtitle: "",
                 iconUrl: Quickshell.iconPath(e.icon, "application-x-executable") };
    }
    function icon(...names) {
        for (const n of names) { const p = Quickshell.iconPath(n, true); if (p) return p; }
        return "";
    }
    function fileKind(f) {
        return f.isDir ? "Folders" : /\bimage$/.test(f.kindName) ? "Images"
             : f.kindName === "PDF document" ? "PDF Documents" : "Documents";
    }
    function chipOf(r) {
        return r.kind === "app" ? "Applications" : r.kind === "file" ? fileKind(r)
             : r.kind === "clip" ? "Clipboard" : "";
    }
    // fluidity-search rows -> Golden Gate rows: a title and a one-line grey subtitle.
    function present(r) {
        const add = o => Object.assign({}, r, o);
        if (r.kind === "file") {
            const [maj, ...rest] = r.iconName.split("-");
            return add({ title: r.label, subtitle: r.when + " – " + r.folder,
                         iconUrl: icon(r.iconName, maj + "-x-" + rest.join("-"), r.iconFallback, "text-x-generic") });
        }
        if (r.kind === "calc")
            return add({ title: r.label, subtitle: view.text.trim(), iconUrl: icon("accessories-calculator", "calc") });
        if (r.kind === "web")
            return add({ title: r.term, subtitle: "Search the Web – " + r.engine, iconUrl: icon("safari", "web-browser") });
        if (r.kind === "clip")
            return add({ title: r.label, subtitle: "Clipboard", iconUrl: icon("app.getclipboard.Clipboard", "edit-paste") });
        if (r.kind === "ask")
            return add({ title: "Ask Claude", subtitle: "", iconUrl: icon("claude", "dialog-question") });
        return add({ title: r.label, subtitle: "" });
    }
    // Everything for the text, before the chip filter.
    readonly property var allRows: {
        const q = view.text.trim().toLowerCase();
        const ext = extNow.map(present);
        if (filter === "Clipboard") return ext;
        if (filter === "Applications" && q === "") return appRows("", 500);
        if (q === "") return [];
        if (prefixOf(view.text)) return ext;
        const kind = k => ext.filter(r => r.kind === k);
        return [].concat(kind("ask"), kind("calc"), appRows(q, filter === "Applications" ? 500 : 8),
                         kind("file"), kind("web"));
    }
    readonly property var rows: filter === "" || filter === "Clipboard" ? allRows
        : filter === "Files" ? allRows.filter(r => r.kind === "file")
        : allRows.filter(r => chipOf(r) === filter)
    readonly property var chips: {
        const have = new Set(allRows.map(chipOf));
        have.add("Clipboard");
        if (filter) have.add(filter);
        return ["Applications", "Files", "Documents", "Folders", "Images", "PDF Documents", "Clipboard"]
            .filter(c => have.has(c));
    }

    function activate(i, reveal) {
        const r = rows[i];
        if (!r || (reveal && r.kind !== "file")) return;
        if (r.kind === "ask") { startAsk(view.text.trim()); return; }
        Panels.close();
        if (r.kind === "app") {
            try { counts = JSON.parse(store.text()) } catch (e) {}
            counts[r.app.id] = (counts[r.app.id] ?? 0) + 1;
            store.setText(JSON.stringify(counts));
            Quickshell.execDetached(["uwsm", "app", "--", r.app.id + ".desktop"]);
        } else if (r.kind === "calc") Quickshell.execDetached(["wl-copy", "--", r.copy]);
        else if (r.kind === "file" && reveal) Quickshell.execDetached(["fluidity-search", "reveal", r.path]);
        else if (r.kind === "file") Quickshell.execDetached(["uwsm", "app", "--", "xdg-open", r.path]);
        else if (r.kind === "web") Quickshell.execDetached(["uwsm", "app", "--", "xdg-open", r.url]);
        else if (r.kind === "clip") Quickshell.execDetached(["fluidity-search", "copy-clip", r.id]);
    }
    function searchWeb() {
        const t = view.text.trim();
        if (t === "") return;
        Panels.close();
        Quickshell.execDetached(["uwsm", "app", "--", "xdg-open",
                                 "https://www.google.com/search?q=" + encodeURIComponent(t)]);
    }

    FileView {
        id: store
        path: Quickshell.env("HOME") + "/.local/state/fluidity/launcher.json"
        printErrors: false
        onLoaded: { try { spot.counts = JSON.parse(text()) } catch (e) {} }
    }

    // ---- Ask Claude: the answer window ---------------------------------------------------
    // `fluidity-search ask` runs `claude -p` (chat only) in ~/.cache/fluidity/ask; follow-ups resume
    // the same session, and the expand arrows open it in Claude Code there.

    property bool askOpen: false
    property var askMessages: []        // { role: "user" | "claude" | "error", text }
    property string askSession: ""
    property int askRun: 0              // bumps per conversation; late answers to old ones are dropped
    property var askJob: null
    property real askX: 0
    property real askY: 0
    readonly property bool askBusy: askMessages.length > 0 && askMessages[askMessages.length - 1].role === "user"
    readonly property string askDir: Quickshell.env("HOME") + "/.cache/fluidity/ask"

    function startAsk(question) {
        if (question === "") return;
        Panels.close();
        stopAsk();
        if (!askOpen) {
            askX = Math.round(targetScreen.width / 2 + 140);
            askY = Math.round(targetScreen.height * 0.14);
        }
        askOpen = true;
        sendAsk(question);
        Qt.callLater(() => ask.focusInput());
    }
    function sendAsk(question) {
        askMessages = askMessages.concat([{ role: "user", text: question }]);
        const job = askProcess.createObject(spot, { run: askRun });
        job.command = ["fluidity-search", "ask"].concat(askSession ? ["--resume", askSession] : [], ["--", question]);
        job.running = true;
        askJob = job;
    }
    function askAnswered(run, text) {
        if (run !== askRun) return;
        let out;
        try { out = JSON.parse(text); } catch (e) { out = { answer: "", session: "", error: "No answer came back." }; }
        if (out.session) askSession = out.session;
        askMessages = askMessages.concat([out.error ? { role: "error", text: out.error }
                                                    : { role: "claude", text: out.answer }]);
    }
    function stopAsk() {
        askRun++;
        if (askJob && askJob.running) askJob.running = false;
        askJob = null;
        askMessages = [];
        askSession = "";
    }
    Component {
        id: askProcess
        Process {
            id: job
            property int run
            stdout: StdioCollector {
                onStreamFinished: {
                    spot.askAnswered(job.run, text);
                    Qt.callLater(() => job.destroy());
                }
            }
        }
    }

    PanelWindow {
        id: askWin

        readonly property int pad: 24   // room for the glass's shadow
        screen: spot.targetScreen
        visible: spot.askOpen
        anchors { top: true; left: true }
        margins { top: Math.round(spot.askY) - pad; left: Math.round(spot.askX) - pad }
        implicitWidth: ask.width + 2 * pad
        implicitHeight: ask.height + 2 * pad
        color: "transparent"
        exclusiveZone: -1
        WlrLayershell.namespace: "qs-lyric-ask"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        AskPanelView {
            id: ask
            x: askWin.pad
            y: askWin.pad
            messages: spot.askMessages
            busy: spot.askBusy
            canExpand: spot.askSession !== ""
            onCloseRequested: { spot.askOpen = false; spot.stopAsk(); }
            onExpandRequested: {
                Quickshell.execDetached(["uwsm", "app", "--", "xdg-terminal-exec", "--dir=" + spot.askDir,
                                         "claude", "--resume", spot.askSession]);
                spot.askOpen = false;
                spot.stopAsk();
            }
            onFollowUp: text => spot.sendAsk(text)
            onDragBy: (dx, dy) => {
                const s = spot.targetScreen, p = askWin.pad;
                spot.askX = Math.max(p, Math.min(s.width - ask.width - p, spot.askX + dx));
                spot.askY = Math.max(p, Math.min(s.height - ask.height - p, spot.askY + dy));
            }
        }
    }
}
