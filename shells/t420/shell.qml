// T420 dwm: "T420 + DWM + Artix is the ultimate just works setup" (r/unixporn 1xvpvoo, no dotfiles) in Quickshell.
// dwm's one-line bar across the top of every screen: tags, layout symbol ([]= tile / [M] monocle = maximise),
// the focused title on dwm's "selected" green, and a dwmblocks-style emoji status. No gaps, a 2 px green border.
// fluidity-theme starts it (`qs -c t420`); Super+` hides or shows the bar (dwm's togglebar).
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    Sys { id: live }
    function act(w, a) {
        if (w === "monocle") Hyprland.dispatch('hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })');
        else live.act(w, a);
    }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 22; color: "transparent"
                WlrLayershell.namespace: "qs-t420-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => root.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
