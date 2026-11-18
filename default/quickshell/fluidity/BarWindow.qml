import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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
    Region { id: shownMask; item: bar.children[0]; Region { item: island } Region { item: rightHit } Region { item: bar.appsItem } }
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
        onAppClicked: (v, a) => Island.toggle(v, a)
        onWorkspaceClicked: id => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`)
    }
    Item { id: rightHit; anchors.right: parent.right; y: 14; width: 420; height: 40 }

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
