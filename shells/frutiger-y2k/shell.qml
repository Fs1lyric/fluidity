// Frutiger Y2K: Jp20061's "a mix between Y2K and Frutiger Aero" (r/unixporn 1x8hhh0, no dotfiles) rebuilt in
// Quickshell: white frosted glass over the sky. Three top pills (HYPER AERO + workspaces / clock / status),
// the CHRONO clock, the glossy blue Aero player, SKY ARC, ATMOS and the TELEMETRY column on the right.
// fluidity-theme starts it (`qs -c frutiger-y2k`); Super+` hides the telemetry column, Super+F1 the desktop cards.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool telemetry: true
    property bool cards: true
    Sys { id: live }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 40; color: "transparent"
                WlrLayershell.namespace: "qs-fy-bar"
                TopView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.telemetry
                anchors { top: true; right: true; bottom: true }
                margins { right: 10; bottom: 10 }
                implicitWidth: 240; color: "transparent"
                WlrLayershell.namespace: "qs-fy-telemetry"
                TelemetryView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.cards
                anchors { top: true; left: true; right: true; bottom: true }
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-fy-desk"
                color: "transparent"
                DeskView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.telemetry = !root.telemetry } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.cards = !root.cards } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
