// Kurzgesagt: quandangv's "[BSPWM] another Kurzgesagt theme" (r/unixporn mulrrw, gitlab quandangv/yuzubar +
// theme-changer) rebuilt in Quickshell: his yuzubar along the bottom (teal, Montserrat Light, salmon
// underlines and blocks) over the nuclear-plant Kurzgesagt wallpaper, with see-through mint terminals
// (theme feel). fluidity-theme starts it (`qs -c kurzgesagt`); Super+` hides or shows the bar.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    FontLoader { source: "Montserrat-Light.ttf" }
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-kz-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
