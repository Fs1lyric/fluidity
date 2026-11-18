// Beige Pixel: a-long-username's "[Xfce] Beige and pixel art" (r/unixporn 137hrcw) rebuilt in Quickshell on
// Heikki Luhtala's pixel Amiga mouse ("Hiiri"): the dark brown polybar inset at the top, the big pixel clock
// with the date and forecast on the right, and the little coloured dock at the bottom.
// fluidity-theme starts it (`qs -c beige-pixel`); Super+` hides or shows the clock and dock.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool widgets: true
    FontLoader { source: "Silkscreen-Bold.ttf" }
    Sys { id: live }
    Forecast { id: fc }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-bp-bar"
                BarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { top: true; right: true }
                margins { top: per.modelData.height * 0.08; right: per.modelData.width * 0.04 }
                implicitWidth: clock.implicitWidth; implicitHeight: clock.implicitHeight
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-bp-clock"
                color: "transparent"
                mask: Region {}
                ClockView { id: clock; now: live.now; days: fc.days }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.widgets
                anchors { bottom: true }
                margins { bottom: 10 }
                implicitWidth: dock.implicitWidth; implicitHeight: 50
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-bp-dock"
                DockView { id: dock; onAct: (w, a) => live.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.widgets = !root.widgets } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
