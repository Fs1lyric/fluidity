// Pip-Boy: Frosty_Pin9045's "Pip-Boy-3000 as a daily driver" (r/unixporn 1nortdo, sway, github Tong-ST/Funcher)
// rebuilt in Quickshell. A bracketed phosphor-green status row on top (STATS: HP = battery, AP = free memory,
// XP = disk, RAD = CPU load; S.P.E.C.I.A.L. = workspaces 1-7; SKILLS: volume, network, date, lock) and the
// Vault-Tec row at the bottom whose STATS / INV / MAP / DATA / RADIO tabs open the Pip-Boy screen.
// fluidity-theme starts it (`qs -c pip-boy`); Super+` hides the bars, Super+F1 opens the Pip-Boy screen.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool shown: true
    property bool open: false
    property string tab: "STATS"
    function openTab(t) { if (root.open && root.tab === t) root.open = false; else { root.tab = t; root.open = true } }
    FontLoader { source: "ShareTechMono.ttf" }
    Sys { id: live }
    Cava { id: cava; bars: 40; active: root.open && root.tab === "RADIO" }
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { top: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-pip-top"
                TopView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.shown
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 28; color: "transparent"
                WlrLayershell.namespace: "qs-pip-bottom"
                BottomView { anchors.fill: parent; sys: live; tab: root.open ? root.tab : ""; onPick: t => root.openTab(t) }
            }
            PanelWindow {
                screen: per.modelData
                visible: root.open
                anchors { top: true; bottom: true; left: true; right: true }
                margins { top: 60; bottom: 58; left: 160; right: 160 }
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                WlrLayershell.namespace: "qs-pip-screen"
                WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
                ScreenView { anchors.fill: parent; sys: live; tab: root.tab; levels: cava.levels
                             onAct: (w, a) => live.act(w, a); onPick: t => root.tab = t
                             focus: true; Keys.onEscapePressed: root.open = false }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.shown = !root.shown } }
    IpcHandler { target: "dashboard"; function toggle(): void { root.open = !root.open } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
