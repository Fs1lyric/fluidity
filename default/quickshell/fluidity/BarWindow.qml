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
    Region { id: shownMask; item: bar.children[0]; Region { item: island } Region { item: rightHit } }
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
        title: Island.passiveTitle; body: Island.passiveBody; icon: Island.passiveIcon; value: Island.passiveValue; keyHint: Island.passiveKeys
        MouseArea { anchors.fill: parent; onClicked: Island.toggle(Island.barView === "idle" ? "control" : "notifications", "") }
    }
}
