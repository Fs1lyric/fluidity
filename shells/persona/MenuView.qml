// The Persona 3 pause menu: a blue diagonal sweep and the big slanted command list on the left, the clock and
// party "HP" (battery / CPU / memory) on the right. Up/Down/Enter or the mouse, Esc closes.
import QtQuick

Item {
    id: m
    property var sys
    property int sel: 0
    signal act(string what, var arg)
    signal close()
    readonly property var items: [["SKILL", "launcher"], ["ITEM", "files"], ["EQUIP", "settings"], ["STATUS", "status"],
                                  ["QUEST", "browser"], ["SOCIAL LINK", "terminal"], ["CALENDAR", "calendar"], ["SYSTEM", "power"]]
    function run(i) {
        const w = items[i][1];
        if (w === "status") act("exec", ["ghostty", "-e", "btop"]);
        else if (w === "calendar") act("exec", ["calendio"]);
        else act(w, null);
    }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Escape) m.close();
        else if (e.key === Qt.Key_Down || e.key === Qt.Key_J) m.sel = (m.sel + 1) % items.length;
        else if (e.key === Qt.Key_Up || e.key === Qt.Key_K) m.sel = (m.sel + items.length - 1) % items.length;
        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) m.run(m.sel);
    }
    Rectangle { anchors.fill: parent; color: "#880a0f24"
                MouseArea { anchors.fill: parent; onClicked: m.close() } }
    // the diagonal blue sweep
    Rectangle { x: -m.width * 0.15; y: -m.height * 0.2; width: m.width * 0.62; height: m.height * 1.5; rotation: 14
                gradient: Gradient { orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#e0033a91" } GradientStop { position: 0.8; color: "#c0115ea4" } GradientStop { position: 1; color: "#0017a9d5" } } }
    Rectangle { x: m.width * 0.36; y: -m.height * 0.2; width: m.width * 0.012; height: m.height * 1.5; rotation: 14; color: "#5ec8e1" }
    Column {
        x: m.width * 0.05; y: m.height * 0.12; spacing: m.height * 0.004
        Repeater {
            model: m.items
            Item {
                required property var modelData
                required property int index
                readonly property bool on: index === m.sel
                width: m.width * 0.4; height: m.height * 0.095
                x: index * m.width * 0.018
                Rectangle { visible: parent.on; anchors.verticalCenter: parent.verticalCenter; x: -m.width * 0.01
                            width: lbl.implicitWidth + m.width * 0.03; height: parent.height * 0.78; color: "white"; rotation: -4 }
                Text { id: lbl; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[0]; rotation: -4
                       font.family: "Anton"; font.pixelSize: m.height * (parent.on ? 0.088 : 0.07); font.italic: true
                       color: parent.on ? "#0a1a4a" : "#e2f1f9"; style: parent.on ? Text.Normal : Text.Outline; styleColor: "#0a1a4a" }
                MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: m.sel = parent.index; onClicked: m.run(parent.index) }
            }
        }
    }
    Column {
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: m.width * 0.04; bottomMargin: m.height * 0.08 }
        spacing: m.height * 0.012
        Text { anchors.right: parent.right; text: Qt.formatDateTime(m.sys?.now ?? new Date(), "M/d ddd").toUpperCase()
               font.family: "Anton"; font.pixelSize: m.height * 0.06; color: "white" }
        Repeater {
            model: [["HP", m.sys?.battery ?? 1, "#5ee86a"], ["SP", 1 - (m.sys?.cpu ?? 0), "#ff4fb8"], ["MEM", 1 - (m.sys?.ram ?? 0), "#5ec8e1"]]
            Row {
                required property var modelData
                anchors.right: parent.right; spacing: 14
                Text { text: parent.modelData[0]; font.family: "Anton"; font.pixelSize: m.height * 0.03; color: "#e2f1f9"; width: m.height * 0.07 }
                Rectangle { width: m.width * 0.16; height: m.height * 0.018; y: m.height * 0.012; color: "#0a0f24"; border.color: "white"; border.width: 2
                            Rectangle { x: 3; y: 3; height: parent.height - 6; width: (parent.width - 6) * Math.max(0, Math.min(1, parent.parent.modelData[1])); color: parent.parent.modelData[2] } }
                Text { text: Math.round(parent.modelData[1] * 100); font.family: "Anton"; font.pixelSize: m.height * 0.03; color: "white"; width: m.height * 0.06 }
            }
        }
    }
}
