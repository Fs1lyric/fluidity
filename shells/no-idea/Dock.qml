// His tint2 launcher, always on the bottom (reserves its height). Apps mapped to this machine.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: dock
    anchors.bottom: true
    implicitWidth: view.implicitWidth; implicitHeight: view.implicitHeight + 8
    exclusiveZone: implicitHeight
    color: "transparent"
    WlrLayershell.namespace: "qs-ni-dock"
    DockView {
        id: view
        anchors.top: parent.top
        iconDir: Qt.resolvedUrl("shell.qml").toString().replace(/shell\.qml$/, "") + "candy/"   // bundled candy-icons (GPL-3.0)
        apps: [
            { icon: "flameshot", cmd: ["fluidity-shell", "screenshot", "region"] },
            { icon: "zen", cmd: ["uwsm-app", "--", "zen-browser"] },
            { icon: "spotify", cmd: ["uwsm-app", "--", "spotify"] },
            { icon: "obsidian", cmd: ["uwsm-app", "--", "obsidian"] },
            { icon: "nvim", cmd: ["uwsm-app", "--", "ghostty", "-e", "nvim"] },
            { icon: "calendar", cmd: ["uwsm-app", "--", "calendio"] },
            { icon: "vesktop", cmd: ["uwsm-app", "--", "vesktop"] },
            { icon: "com.mitchellh.ghostty", cmd: ["uwsm-app", "--", "ghostty"] },
            { icon: "thunar", cmd: ["uwsm-app", "--", "thunar"] },
            { icon: "btop", cmd: ["uwsm-app", "--", "ghostty", "-e", "btop"] }
        ]
        onLaunch: c => Quickshell.execDetached(c)
    }
}
