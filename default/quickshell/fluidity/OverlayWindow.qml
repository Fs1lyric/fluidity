import QtQuick
import Quickshell
import Quickshell.Wayland
import "views"

// The interactive island: full screen, takes the keyboard, the island grows from the bar's spot.
// A click outside closes it.
PanelWindow {
    id: w
    screen: Island.screen
    visible: Island.overlayShown
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "fluidity-island"
    WlrLayershell.layer: WlrLayer.Overlay
    // the keyboard is asked for when the window appears (Hyprland ignores a later request), and given back when it hides;
    // that's why a picked emoji or a paste waits until the island is gone (Island.pasteDelay)
    WlrLayershell.keyboardFocus: Island.overlayShown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    onVisibleChanged: if (visible) v.forceActiveFocus()
    Connections { target: Island; function onViewChanged() { if (Island.view !== "idle") v.forceActiveFocus() } }

    Rectangle { anchors.fill: parent; color: "#000000"; opacity: Island.view === "idle" || Island.view === "dockkeys" ? 0 : 0.22; Behavior on opacity { NumberAnimation { duration: 200 } } }
    MouseArea { anchors.fill: parent; onClicked: Island.close() }

    IslandView {
        id: v
        anchors.horizontalCenter: parent.horizontalCenter; y: 14
        focus: true
        pal: Theme.pal
        view: Island.view
        index: Island.index
        query: Island.query
        placeholder: Island.placeholder
        items: Island.items
        groups: Island.groups
        preview: Island.preview
        calc: Island.calc
        cats: Island.cats
        cat: Island.cat
        title: Island.title
        body: Island.body
        keyHint: Island.keyHint
        app: Apps.data
        screenW: w.width
        screenH: w.height
        onActivated: i => { if (Apps.views.includes(Island.target)) Apps.picked(Island.target, i) }
        song: Island.song
        playing: Island.player?.isPlaying ?? false
        clock: Status.clock
        extra: Status.focusText || Status.nextText
        thumbDelegate: Component {
            ScreencopyView { captureSource: parent?.win?.toplevel?.wayland ?? null; live: true }
        }
        Keys.onPressed: event => { if (Island.key(event)) event.accepted = true }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }  // clicks on the island don't close it
    }
}
