// The survival HUD rebuilt as a status bar (hooss_only's mapping): hearts = free memory, hunger = battery,
// the XP bar = CPU load (level = CPU %), and the hotbar = workspaces 1-9 (an occupied one holds a block with
// its window count, the focused one gets the white selector). Scroll to switch, click a slot to go there.
import QtQuick

Item {
    id: h
    property var sys
    signal act(string what, var arg)
    readonly property int s: 2                     // pixel scale
    implicitWidth: 182 * s; implicitHeight: 44 * s
    readonly property var heart: [".KK.KK.", "KRRKRRK", "KRWRRRK", "KRRRRRK", ".KRRRK.", "..KRK..", "...K..."]
    readonly property var heartEmpty: [".KK.KK.", "K..K..K", "K.....K", "K.....K", ".K...K.", "..K.K..", "...K..."]
    readonly property var food: ["....KK.", "...KBBK", "..KBBBK", ".KBBBK.", "KWKKK..", "KWK....", ".K....."]
    readonly property var foodEmpty: ["....KK.", "...K..K", "..K...K", ".K...K.", "KWKKK..", "KWK....", ".K....."]
    readonly property var block: ["GGGGGGGG", "GgGGGgGG", "DGDgDGDg", "DDdDDDdD", "DdDDdDDD", "DDDdDDdD", "dDDDDdDD", "DDdDDDDD"]
    readonly property real mem: 1 - (sys?.ram ?? 0)
    readonly property real food_: sys?.battery ?? 1
    // hearts (left) and hunger (right), 10 each, in half steps like the game
    Row {
        x: 0; y: 0; spacing: 1 * h.s
        Repeater { model: 10
                   Pix { required property int index; scale: h.s; rows: h.mem * 10 > index + 0.25 ? h.heart : h.heartEmpty
                         colors: ({ K: "#1a0000", R: "#e01c1c", W: "#ff9a9a" }) } }
    }
    Row {
        anchors.right: parent.right; y: 0; spacing: 1 * h.s; layoutDirection: Qt.RightToLeft
        Repeater { model: 10
                   Pix { required property int index; scale: h.s; rows: h.food_ * 10 > index + 0.25 ? h.food : h.foodEmpty
                         colors: ({ K: "#2a1405", B: "#b8682a", W: "#e8e0d0" }) } }
    }
    // XP bar
    Rectangle {
        x: 0; y: 9 * h.s; width: 182 * h.s; height: 5 * h.s; color: "#1a1a1a"
        Rectangle { x: h.s; y: h.s; height: 3 * h.s; width: (parent.width - 2 * h.s) * Math.max(0, Math.min(1, h.sys?.cpu ?? 0)); color: "#80ff20" }
        Row { x: h.s; y: h.s; Repeater { model: 18; Rectangle { required property int index; width: 10 * h.s; height: 3 * h.s; color: "transparent"
                                                               Rectangle { anchors.right: parent.right; width: h.s; height: parent.height; color: "#1a1a1a"; opacity: 0.6 } } } }
    }
    Text { anchors.horizontalCenter: parent.horizontalCenter; y: 3 * h.s; text: Math.round((h.sys?.cpu ?? 0) * 100)
           font.family: "Monocraft"; font.pixelSize: 8 * h.s; color: "#80ff20"; style: Text.Outline; styleColor: "#000000" }
    // hotbar
    Rectangle {
        x: 0; y: 22 * h.s; width: 182 * h.s; height: 22 * h.s; color: "#8b8b8b"; border.color: "#000000"; border.width: h.s
        Row {
            x: h.s; y: h.s
            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                Item {
                    required property int modelData
                    readonly property var tag: (h.sys?.tags ?? []).find(t => t.id === modelData) ?? { count: 0, state: "empty" }
                    width: 20 * h.s; height: 20 * h.s
                    Rectangle { anchors.fill: parent; anchors.margins: h.s; color: "#8b8b8b"; border.color: "#373737"; border.width: h.s
                                Rectangle { anchors.fill: parent; anchors.leftMargin: h.s; anchors.topMargin: h.s; color: "transparent"; border.color: "#c6c6c6"; border.width: h.s; opacity: 0.5 } }
                    Pix { anchors.centerIn: parent; visible: parent.tag.count > 0; scale: h.s * 1.5; rows: h.block
                          colors: ({ G: "#5d9c3a", g: "#7cbd52", D: "#8a5a3a", d: "#6b4428" }) }
                    Text { anchors { right: parent.right; bottom: parent.bottom; rightMargin: 2 * h.s; bottomMargin: h.s }
                           visible: parent.tag.count > 1; text: parent.tag.count; font.family: "Monocraft"; font.pixelSize: 8 * h.s; color: "white"
                           style: Text.Raised; styleColor: "#3f3f3f" }
                    Rectangle { visible: parent.tag.state === "focused"; anchors.fill: parent; anchors.margins: -h.s; color: "transparent"; border.color: "#ffffff"; border.width: 2 * h.s
                                Rectangle { anchors.fill: parent; anchors.margins: -h.s; color: "transparent"; border.color: "#000000"; border.width: h.s } }
                    MouseArea { anchors.fill: parent; onClicked: h.act("ws", parent.modelData) }
                }
            }
        }
        WheelHandler { onWheel: e => h.act("wsStep", e.angleDelta.y > 0 ? -1 : 1) }
    }
}
