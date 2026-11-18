import QtQuick
import Quickshell
import Quickshell.Wayland
import "views"

// The slices theme picker (ThemeSlicesView, ported MIT code), full screen.
PanelWindow {
    id: w
    screen: ThemePickerState.screen
    visible: ThemePickerState.shown
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "fluidity-themes"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ThemePickerState.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea { anchors.fill: parent; onClicked: ThemePickerState.shown = false }
    ThemeSlicesView {
        anchors.fill: parent
        opened: ThemePickerState.shown
        rows: ThemePickerState.rows
        selectedImage: ThemePickerState.rows.split("\n").map(r => r.split("\t")[0]).find(p => p.split("/").pop().replace(/\.[^.]+$/, "") === ThemePickerState.current) ?? ""
        devicePixelRatio: w.screen?.devicePixelRatio ?? 1
        dimColor: Theme.pal.bg
        foreground: Theme.pal.fg
        selectedBorder: Theme.pal.accent
        onApplied: name => ThemePickerState.apply(name)
        onCanceled: ThemePickerState.shown = false
    }
}
