// Bottom workspace bar (elenapan's taglist): transparent, 45 px, reserves its space like her wibar.
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: bar
    signal menu()
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 45
    exclusiveZone: 45
    color: "transparent"
    WlrLayershell.namespace: "qs-ml-tagbar"

    readonly property string dir: Qt.resolvedUrl("shell.qml").toString().replace(/shell\.qml$/, "")
    readonly property var tags: {
        const focused = Hyprland.focusedWorkspace?.id ?? -1;
        const wins = Hyprland.toplevels.values;
        const byId = {};
        for (const w of Hyprland.workspaces.values) byId[w.id] = w;
        const out = [];
        for (let i = 1; i <= 10; i++) {
            const w = byId[i];
            const busy = wins.some(t => t.workspace?.id === i);
            out.push({ id: i, state: i === focused ? "focused" : w?.urgent ? "urgent" : busy ? "occupied" : "empty" });
        }
        return out;
    }

    TagbarView {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        tagDir: bar.dir + "taglist/"
        iconDir: bar.dir + "icons/"
        tags: bar.tags
        onClicked: id => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${id}" })`)
        onMenuClicked: bar.menu()
        onLayoutClicked: Hyprland.dispatch(`hl.dsp.window.float({ action = "toggle" })`)
    }
}
