// E-ink: csarr's e-ink study rice (r/unixporn 1qw1cpe, github csarr/dots) rebuilt in Quickshell.
// His DankMaterialShell bar along the bottom (black, square, iA Writer Quattro) and its control centre.
// fluidity-theme starts it (`qs -c e-ink`) in place of the luminescent bar; `qs -c e-ink ipc call sidebar toggle`
// (Super+`) opens the control centre. Notifications, OSD and the theme picker stay in `qs -c fluidity`.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool ccOpen: false
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 30
                color: "transparent"
                WlrLayershell.namespace: "qs-eink-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a); onControlCenter: root.ccOpen = !root.ccOpen }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.ccOpen
                anchors { bottom: true; right: true }
                margins { bottom: 6; right: 6 }
                implicitWidth: cc.implicitWidth; implicitHeight: cc.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-eink-cc"
                WlrLayershell.keyboardFocus: root.ccOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                ControlCenterView { id: cc; anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a)
                                    focus: true; Keys.onEscapePressed: root.ccOpen = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.ccOpen = !root.ccOpen } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
