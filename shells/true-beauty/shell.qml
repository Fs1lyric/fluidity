// True Beauty: Minersonic15's "best rice you'll see this year" (r/unixporn 1vbjcq5, github
// Minersonic15/True-Beauty-hyprland) rebuilt in Quickshell. Stock Waybar on top, his eww boxes over everything
// ("SUper COol ass computer!!" and the "remove ads $9.99" corners, eww.yuck geometry), and Hyprland's splash
// line. The 200 px rounding, 20 px cyan/magenta border, -50 / 80 gaps and 0.9 / 0.4 opacity come from the theme.
// fluidity-theme starts it (`qs -c true-beauty`); Super+` hides or shows the boxes.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool boxes: true
    Sys { id: live }
    // eww.yuck windows (monitor 1's set): [text, anchor, x, y, w, h]
    readonly property var ewwBoxes: [
        ["SUper COol ass computer!!", "top", 20, 20, 1000, 50],
        ["remove ads $9.99", "bottom right", 20, 20, 200, 40],
        ["remove ads $9.99", "top left", 60, 250, 200, 90],
        ["remove ads $9.99", "top right", 100, 60, 200, 60]]
    Variants {
        model: Quickshell.screens
        Scope {
            id: per
            required property var modelData
            PanelWindow {
                screen: per.modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 30; color: "transparent"
                WlrLayershell.namespace: "qs-tb-waybar"
                WaybarView { anchors.fill: parent; sys: live; onAct: (w, a) => live.act(w, a) }
            }
            Repeater {
                model: root.boxes ? root.ewwBoxes : []
                PanelWindow {
                    required property var modelData
                    screen: per.modelData
                    anchors { top: modelData[1].includes("top"); bottom: modelData[1].includes("bottom")
                              left: modelData[1].includes("left"); right: modelData[1].includes("right") }
                    // eww centres "top" windows horizontally and offsets the rest from their corner
                    margins { top: modelData[1].includes("top") ? modelData[3] : 0; bottom: modelData[1].includes("bottom") ? modelData[3] : 0
                              left: modelData[1].includes("left") ? modelData[2] : 0; right: modelData[1].includes("right") ? modelData[2] : 0 }
                    implicitWidth: modelData[4]; implicitHeight: modelData[5]
                    exclusionMode: ExclusionMode.Ignore
                    WlrLayershell.layer: WlrLayer.Overlay
                    WlrLayershell.namespace: "qs-tb-eww"
                    color: "transparent"
                    AdBox { anchors.fill: parent; text: parent.modelData[0] }
                }
            }
            // Hyprland's splash line, bottom centre over the wallpaper
            PanelWindow {
                screen: per.modelData
                anchors { bottom: true; left: true; right: true }
                implicitHeight: 40
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "qs-tb-splash"
                color: "transparent"
                mask: Region {}
                Text { anchors.centerIn: parent; text: "\"the only wayland compositor powered by a chicken rat\""; color: Qt.rgba(1, 1, 1, 0.75)
                       font.family: "Sans"; font.pixelSize: 13 }
            }
        }
    }
    IpcHandler { target: "sidebar"; function toggle(): void { root.boxes = !root.boxes } }
    IpcHandler { target: "exit"; function toggle(): void { live.act("power", null) } }
}
