// Liquid Glass: Aeuna's Plasma "liquiding my glass" (r/unixporn 1rngle9) rebuilt in Quickshell.
// Workspace pills, now playing and audio bars over the wallpaper; one long glass dock with tray and clock;
// the glass right-click menu on the desktop. Hyprland blurs behind every qs-lg-* layer (theme feel).
// fluidity-theme starts it (`qs -c liquid-glass`) in place of the luminescent bar; `qs -c liquid-glass ipc call
// sidebar toggle` (Super+`) hides or shows the dock. Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool dock: true
    property var menuAt: null        // { screen, x, y } while the desktop menu is open
    readonly property string iconDir: "file://" + Quickshell.env("HOME") + "/.local/share/icons/WhiteSur/apps/scalable/"
    readonly property var apps: [
        { icon: "zen-browser", cmd: ["bash", "-c", "zen-browser || firefox"] }, { icon: "discord", cmd: ["vesktop"] },
        { icon: "org.gnome.Nautilus", cmd: ["bash", "-c", "thunar || nautilus"] }, { icon: "com.mitchellh.ghostty", cmd: ["ghostty"] },
        { icon: "utilities-system-monitor", cmd: ["ghostty", "-e", "btop"] }, { icon: "preferences-system", cmd: ["lyric-settings"] },
        { icon: "visual-studio-code", cmd: ["bash", "-c", "code || zed || ghostty -e nvim"] },
        { icon: "applets-screenshooter", cmd: ["bash", "-c", "grim -g \"$(slurp)\" - | wl-copy"] }]
    Sys { id: live }
    Cava { id: cava; bars: 24 }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 64; exclusiveZone: 30; color: "transparent"
                WlrLayershell.namespace: "qs-lg-top-noblur"
                TopView { anchors.fill: parent; sys: live; levels: cava.levels
                          onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.dock
                anchors { bottom: true; left: true; right: true }
                margins { left: 86; right: 86; bottom: 8 }
                implicitHeight: 52; color: "transparent"
                WlrLayershell.namespace: "qs-lg-dock"
                DockView { anchors.fill: parent; sys: live; iconDir: root.iconDir; apps: root.apps
                           onAct: (w, a) => live.act(w, a); onLaunch: c => live.act("exec", c) }
            }
            // the desktop itself: right-click opens the glass menu
            PanelWindow {
                screen: per.modelData
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-lg-desktop-noblur"
                color: "transparent"
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.RightButton
                            onClicked: m => root.menuAt = { screen: per.modelData, x: m.x, y: m.y } }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.menuAt !== null && root.menuAt.screen === per.modelData
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "qs-lg-menu"
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                color: "transparent"
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onClicked: root.menuAt = null }
                DeskMenuView {
                    x: Math.min(root.menuAt?.x ?? 0, parent.width - width - 8); y: Math.min(root.menuAt?.y ?? 0, parent.height - height - 8)
                    width: implicitWidth; height: implicitHeight
                    focus: true; Keys.onEscapePressed: root.menuAt = null
                    onPick: w => { root.menuAt = null; root.desk(w) }
                }
            }
        }
    }
    function desk(w) {
        const sh = c => live.act("exec", ["bash", "-c", c]);
        if (w === "new") sh('d=~/Desktop/"New Folder"; n=1; while [ -e "$d" ]; do n=$((n+1)); d=~/Desktop/"New Folder $n"; done; mkdir -p "$d"');
        else if (w === "paste") sh('mkdir -p ~/Desktop && wl-paste > ~/Desktop/"Pasted $(date +%F\\ %H.%M.%S).txt"');
        else if (w === "wallpaper") sh("qs -c fluidity ipc call panel toggle wallpaper");
        else if (w === "display") sh("nwg-displays || lyric-settings displays");
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.dock = !root.dock } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
