// The To-Do card: header with the count left, outlined checkboxes, add field and "clear done (n)".
import QtQuick
import "Pal.js" as P

Rectangle {
    id: t
    property var sys
    signal act(string what, var arg)
    readonly property var todos: sys?.todos ?? []
    width: 300; height: 420; radius: 14
    color: P.paper; border.color: P.ink; border.width: 3
    Row {
        x: 14; y: 12; spacing: 10
        Rectangle { width: 34; height: 34; radius: 9; color: P.light; border.color: P.ink; border.width: 2
                    Text { anchors.centerIn: parent; text: "󰄲"; font.family: P.icon; font.pixelSize: 17; color: P.ink } }
        Column { Text { text: "To-Do"; font.family: P.round; font.pixelSize: 17; font.weight: Font.Black; color: P.ink }
                 Text { text: t.todos.filter(x => !x.done).length + " left"; font.family: P.round; font.pixelSize: 11; color: P.mid } }
    }
    Rectangle { x: 14; y: 56; width: parent.width - 28; height: 1; color: P.light }
    ListView {
        x: 14; y: 64; width: parent.width - 28; height: parent.height - 150; clip: true; spacing: 8
        model: t.todos
        delegate: Row {
            required property var modelData
            required property int index
            spacing: 10; width: ListView.view.width
            Rectangle { width: 18; height: 18; radius: 4; border.color: P.ink; border.width: 2; color: parent.modelData.done ? P.mid : "transparent"
                        Text { anchors.centerIn: parent; visible: parent.parent.modelData.done; text: "✓"; color: "white"; font.pixelSize: 12; font.bold: true }
                        MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: t.act("todoToggle", parent.parent.index) } }
            Text { width: parent.width - 30; wrapMode: Text.Wrap; text: parent.modelData.text; font.family: P.round; font.pixelSize: 13; font.weight: Font.Bold
                   color: parent.modelData.done ? P.mid : P.ink; font.strikeout: parent.modelData.done
                   MouseArea { anchors.fill: parent; acceptedButtons: Qt.RightButton; onClicked: t.act("todoRemove", parent.parent.index) } }
        }
    }
    Rectangle {
        x: 14; y: parent.height - 78; width: parent.width - 28; height: 32; radius: 10; color: "#e9f1f4"; border.color: P.ink; border.width: 2
        TextInput { id: inp; x: 10; width: parent.width - 50; anchors.verticalCenter: parent.verticalCenter; font.family: P.round; font.pixelSize: 12; color: P.ink
                    onAccepted: { t.act("todoAdd", text); text = "" }
                    Text { visible: !inp.text; text: "add a task..."; font: inp.font; color: P.mid } }
        Rectangle { anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter } width: 24; height: 24; radius: 6
                    color: P.light; border.color: P.ink; border.width: 2
                    Text { anchors.centerIn: parent; text: "+"; color: P.ink; font.pixelSize: 16; font.bold: true }
                    MouseArea { anchors.fill: parent; onClicked: { t.act("todoAdd", inp.text); inp.text = "" } } }
    }
    Rectangle {
        anchors { right: parent.right; rightMargin: 14; bottom: parent.bottom; bottomMargin: 12 }
        width: cd.implicitWidth + 18; height: 22; radius: 11; color: P.paper; border.color: P.ink; border.width: 2
        Text { id: cd; anchors.centerIn: parent; text: "clear done (" + t.todos.filter(x => x.done).length + ")"; font.family: P.round; font.pixelSize: 11; font.weight: Font.ExtraBold; color: P.ink }
        MouseArea { anchors.fill: parent; onClicked: { for (let i = t.todos.length - 1; i >= 0; i--) if (t.todos[i].done) t.act("todoRemove", i) } }
    }
}
