// The 10 px tag strip along the top (her taglist_box wibar; reserves its height).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: 10
    exclusiveZone: 10
    color: "transparent"
    WlrLayershell.namespace: "qs-pw-tags"

    readonly property var tags: {
        const focused = Hyprland.focusedWorkspace?.id ?? -1, wins = Hyprland.toplevels.values, byId = {};
        for (const w of Hyprland.workspaces.values) byId[w.id] = w;
        const out = [];
        for (let i = 1; i <= 10; i++)
            out.push({ id: i, state: i === focused ? "focused" : byId[i]?.urgent ? "urgent"
                       : wins.some(t => t.workspace?.id === i) ? "occupied" : "empty" });
        return out;
    }
    TagsView { anchors.fill: parent; tags: bar.tags
               onClicked: id => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`) }
}
