import QtQuick
import Quickshell
import Quickshell.Wayland
import "views"

// The Fluid dock at the bottom of each screen (Fluid theme, `fluidity-widgets flip dock`). Always mapped,
// empty and click-through when off (see BarWindow).
PanelWindow {
    id: w
    required property var modelData
    screen: modelData
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 120
    exclusiveZone: Dock.shown ? 74 : 0
    color: "transparent"
    WlrLayershell.namespace: "fluidity-dock"
    WlrLayershell.layer: WlrLayer.Top
    Region { id: shownMask; item: dv.pill }
    Region { id: hiddenMask }
    mask: Dock.shown ? shownMask : hiddenMask
    DockView {
        id: dv
        anchors.fill: parent
        visible: Dock.shown
        pal: Theme.pal
        items: Dock.items
        sel: Island.screen === w.screen ? Dock.sel : -1
        active: Dock.sel >= 0 && Island.screen === w.screen
        onClicked: i => Dock.launch(i)
    }
}
