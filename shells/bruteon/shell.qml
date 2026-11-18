// Bruteon: Darkkal44's neo-brutalism rice (r/unixporn 1vmg29f, github Darkkal44/Bruteon, dots not published yet)
// rebuilt in Quickshell from the post and the repo's three previews: three floating cards on top (apps + Tasks,
// a music card that grows, status + clock), desktop widgets (tasks, pomodoro, clock, calendar, weather) and the
// big dashboard. Thick black lines, hard offset shadows, peach sky.
// fluidity-theme starts it (`qs -c bruteon`); Super+` shows / hides the widgets, Super+F1 (or the clock) the dashboard.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool widgets: true
    property bool dash: false
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: Math.ceil(150 * per.modelData.width / 1366)
                exclusiveZone: Math.ceil(46 * per.modelData.width / 1366)
                color: "transparent"
                WlrLayershell.namespace: "qs-brute-bar"
                mask: Region { Region { item: bar.leftCard } Region { item: bar.midCard } Region { item: bar.rightCard } }
                BarView { id: bar; anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a)
                          onToggleWidgets: root.widgets = !root.widgets; onDashboard: root.dash = !root.dash }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-brute-widgets"
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
                color: "transparent"
                mask: Region { Region { item: wv.cards[0] } Region { item: wv.cards[1] } Region { item: wv.cards[2] } Region { item: wv.cards[3] } Region { item: wv.cards[4] } }
                WidgetsView { id: wv; anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.dash
                anchors { top: true; bottom: true; left: true; right: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "qs-brute-dash"
                WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                color: Qt.rgba(0.1, 0.08, 0.08, 0.25)
                DashboardView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a); onClose: root.dash = false
                                focus: true; Keys.onEscapePressed: root.dash = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.widgets = !root.widgets } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.dash = !root.dash } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
