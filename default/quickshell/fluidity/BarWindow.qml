import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray as Tray
import "views"

// One per screen: the three pills on top. Its island plays the passive views (notification, volume OSD) and
// hides while the overlay island is open on this screen, so it looks like one shape growing.
PanelWindow {
    id: w
    required property var modelData
    screen: modelData
    // Hidden = empty and click-through, never unmapped: a layer window that is hidden can't be brought back here.
    anchors { top: true; left: true; right: true }
    implicitHeight: 140
    exclusiveZone: Island.barShown ? 54 : 0
    color: "transparent"
    WlrLayershell.namespace: "fluidity-bar"
    WlrLayershell.layer: WlrLayer.Top
    Region { id: shownMask; item: bar.children[0]; Region { item: island } Region { item: bar.rightItem } Region { item: bar.appsItem } }
    Region { id: hiddenMask }
    mask: Island.barShown ? shownMask : hiddenMask

    readonly property var ws: {
        const out = [];
        const occupied = new Set(Hyprland.toplevels.values.map(t => t.workspace?.id));
        const max = Math.max(5, ...Hyprland.workspaces.values.filter(x => x.id > 0).map(x => x.id));
        for (let i = 1; i <= Math.min(max, 10); i++)
            out.push({ id: i, active: Hyprland.focusedWorkspace?.id === i, occupied: occupied.has(i) });
        return out;
    }

    // The app row. Each button opens its island view; views land here as they are built (PLAN.md, showcase apps).
    readonly property var apps: [
        { icon: "\u{f003b}", view: "launcher" },
        { icon: "\u{f00ed}", view: "calendar" },
        { icon: "\u{f075a}", view: "media" },
        { icon: "\u{f05a9}", view: "network" },
        { icon: "\u{f00af}", view: "bluetooth" },
        { icon: "\u{f0128}", view: "syspanel" },
        { icon: "\u{f140b}", view: "quickactions" },
        { icon: "\u{f051f}", view: "wellbeing" },
        { icon: "\u{f02d6}", view: "guide" },
        { icon: "\u{f0792}", view: "dock", on: Widgets.shown.includes("dock") },   // the dock: add or remove it
        { icon: "\u{f0e09}", view: "wallpaper" },
        { icon: "\u{f014c}", view: "clipboard" },
        { icon: "\u{f0e51}", view: "leader", arg: "capture" },
        { icon: "\u{f009a}", view: "notifications" },
        { icon: "\u{f0493}", view: "control" }
    ]

    BarView {
        id: bar
        visible: Island.barShown
        anchors.left: parent.left; anchors.right: parent.right
        pal: Theme.pal
        workspaces: w.ws
        wifi: Status.wifi
        volume: Island.sink?.audio ? Math.round(Island.sink.audio.volume * 100) : -1
        muted: Island.sink?.audio?.muted ?? false
        battery: Status.battery
        ai: Status.ai
        apps: w.apps
        weather: Status.weather
        cpu: Math.round(Status.sys.cpu)
        viz: Status.viz
        kb: Status.kb
        bt: Status.bt
        tray: Array.from(Tray.SystemTray.items?.values ?? []).map(t => ({ icon: t.icon, title: t.tooltipTitle || t.title || t.id }))
        onTrayClicked: (i, b) => { const t = Array.from(Tray.SystemTray.items?.values ?? [])[i]; if (!t) return;
            if (b === Qt.RightButton && t.hasMenu) t.display(w, bar.rightItem.x, 56); else if (b === Qt.MiddleButton) t.secondaryActivate(); else t.activate() }
        onFaceClicked: v => Island.toggle(v, "")
        onAppClicked: (v, a) => { if (v === "dock") Island.sh("fluidity-widgets flip dock"); else Island.toggle(v, a) }
        onWorkspaceClicked: id => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`)
    }

    IslandView {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter; y: 14
        pal: Theme.pal
        visible: Island.barShown
        opacity: Island.overlayShown && Island.screen === w.screen ? 0 : 1
        view: Island.barView
        song: Island.song
        playing: Island.player?.isPlaying ?? false
        clock: Status.clock
        extra: Status.focusText || Status.nextText
        title: Island.passiveTitle; body: Island.passiveBody; icon: Island.passiveIcon; value: Island.passiveValue; keyHint: Island.passiveKeys
        MouseArea { anchors.fill: parent; onClicked: Island.toggle(Island.barView === "idle" ? "calendar" : "notifications", "") }
    }
}
