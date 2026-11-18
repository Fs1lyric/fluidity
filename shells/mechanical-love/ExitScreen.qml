// Full-screen exit screen over everything; takes the keyboard while open.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: w
    property bool open: false
    signal close()
    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "qs-ml-exit"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property var commands: ({
        poweroff: ["systemctl", "poweroff"],
        reboot: ["systemctl", "reboot"],
        suspend: ["systemctl", "suspend"],
        exit: ["bash", "-c", "command -v uwsm >/dev/null && uwsm stop || hyprctl dispatch exit"],
        lock: ["bash", "-c", "pidof hyprlock || hyprlock"]
    })

    ExitView {
        id: view
        anchors.fill: parent
        iconDir: Qt.resolvedUrl("shell.qml").toString().replace(/shell\.qml$/, "") + "icons/"
        userName: { const u = Quickshell.env("USER") || "friend"; return u.charAt(0).toUpperCase() + u.slice(1); }
        onClosed: w.close()
        onChosen: a => { w.close(); Quickshell.execDetached(w.commands[a]); }
    }
    onOpenChanged: if (open) view.forceActiveFocus()
}
