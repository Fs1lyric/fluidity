// Boring Dev: jeky's "[Niri] My Boring Dev Setup Helix + Zellij" (r/unixporn 1xm2xqs) rebuilt in Quickshell:
// Noctalia's floating bar with its lavender rim over Catppuccin Mocha, the system tray behind a chevron.
// Helix, Zellij and btop are apps (the theme colours them); niri's look comes from the theme feel.
// fluidity-theme starts it (`qs -c boring-dev`); Super+` hides or shows the bar.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                id: win
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                margins { top: 6; left: Math.round(per.modelData.width * 0.18); right: Math.round(per.modelData.width * 0.18) }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-dev-bar"
                BarView {
                    anchors.fill: parent; sys: live
                    tray: SystemTray.items.values.map(i => ({ icon: i.icon, title: i.title }))
                    onAct: (w, a) => live.act(w, a)
                    onTrayClicked: (i, right) => {
                        const it = SystemTray.items.values[i];
                        if (!it) return;
                        if (right && it.hasMenu) it.display(win, win.width - 200, win.height + 4); else it.activate();
                    }
                }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
