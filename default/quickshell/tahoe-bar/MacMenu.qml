import QtQuick
import Quickshell
import Quickshell.Wayland

// A Tahoe menu on screen: MacMenuView with one level of submenu, click-away and Escape to
// close. Shared by the menu bar and the dock (dock/ symlinks this file).
//
//   open(host, x, y, entries, upward)
//     x, y are host-window coordinates. The menu's top-left lands there, or with `upward`
//     the menu is centred on x and ends at y (dock menus open above the icon).
//     With `leftward` the menu's right edge lands on x (a dock on the right edge).
//
// The menu is drawn inside one full-screen layer surface, not an xdg popup: on Hyprland 0.56
// clicks never reached popups of layer surfaces (they fell through to whatever was behind).
// Anywhere on the layer outside the menu is click-away. The keepLive window (the menu bar)
// is left uncovered so hovering another title still switches menus.
//
// Actions run after the menu has closed, so keyboard focus is back on the app first.
Scope {
    id: root

    property var keepLive: []
    readonly property bool opened: layer.visible

    signal closed()
    signal sideways(int step)

    function open(host, x, y, entries, upward, leftward) {
        sub.visible = false;
        view.entries = entries;
        view.current = -1;
        // Host top-left in screen coordinates: the dock hugs the bottom (or a side, spanning down to
        // the bottom), the bar the top.
        const a = host.anchors;
        const screenH = layer.screen?.height ?? 1080;
        const screenW = layer.screen?.width ?? 1920;
        const hostTop = a && a.bottom ? screenH - host.height : 0;
        const hostLeft = a && a.right && !a.left ? screenW - host.width : 0;
        const ly = hostTop + y - layer.topInset;
        const lx = hostLeft + x;
        const w = view.implicitWidth, h = view.implicitHeight;
        let mx = upward ? lx - w / 2 : leftward ? lx - w : lx;
        let my = upward ? ly - h : ly;
        view.x = Math.max(4, Math.min(mx, screenW - w - 4));
        view.y = Math.max(0, Math.min(my, screenH - layer.topInset - h - 4));
        layer.visible = true;
        view.forceActiveFocus();
    }
    function close() {
        if (!layer.visible) return;
        sub.visible = false;
        layer.visible = false;
        root.closed();
    }
    function trigger(e) {
        if (!e || e.separator || !(e.enabled ?? true) || e.submenu) return;
        close();
        if (e.action) Qt.callLater(e.action);
    }
    function openSub(i) {
        const e = view.entries[i];
        if (!e?.submenu) { sub.visible = false; return; }
        if (sub.visible && sub.parentIndex === i) return;
        sub.parentIndex = i;
        subView.entries = e.submenu;
        subView.current = -1;
        sub.x = view.x + view.width - 3;
        sub.y = view.y + view.rowY(i) - subView.inset;
        sub.visible = true;
    }

    PanelWindow {
        id: layer

        readonly property real topInset: root.keepLive.length ? root.keepLive[0].height : 0

        visible: false
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        margins.top: topInset
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "qs-menu"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Click-away.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onPressed: root.close()
        }

        MacMenuView {
            id: view
            width: implicitWidth
            height: implicitHeight
            focus: true
            onHoveredRow: i => root.openSub(i)
            onActivated: i => {
                if (view.entries[i]?.submenu) { root.openSub(i); subView.step(1); subView.forceActiveFocus(); }
                else root.trigger(view.entries[i]);
            }
            onDismiss: root.close()
            onSideways: s => {
                if (s > 0 && view.entries[view.current]?.submenu) {
                    root.openSub(view.current);
                    subView.step(1);
                    subView.forceActiveFocus();
                } else root.sideways(s);
            }
        }

        Item {
            id: sub
            property int parentIndex: -1
            visible: false
            width: subView.implicitWidth
            height: subView.implicitHeight

            MacMenuView {
                id: subView
                anchors.fill: parent
                onActivated: i => root.trigger(subView.entries[i])
                onDismiss: root.close()
                onSideways: s => {
                    if (s < 0) { sub.visible = false; view.forceActiveFocus(); }
                    else root.sideways(s);
                }
            }
        }
    }
}
