import QtQuick

// Rows for the showcase apps: icon, title, sub line, right-hand meta; the accent pill slides to `sel`.
// rows: [{icon, title, desc, meta, on, dim}]
Item {
    id: l
    property var pal: ({})
    property bool animate: true
    property var rows: []
    property int sel: -1
    property int rowH: 50
    signal picked(int i)
    height: rows.length * rowH
    Grad {
        pal: l.pal; x: 0; width: l.width; height: l.rowH; radius: 18
        y: l.sel * l.rowH; visible: l.sel >= 0 && l.sel < l.rows.length
        Behavior on y { enabled: l.animate; SpringAnimation { spring: 5; damping: 0.34; epsilon: 0.3 } }
    }
    Repeater {
        model: l.rows
        Item {
            readonly property bool lit: index === l.sel
            y: index * l.rowH; width: l.width; height: l.rowH
            opacity: modelData.dim ? 0.5 : 1
            Rectangle {
                id: ic; x: 10; width: 32; height: 32; radius: 11; anchors.verticalCenter: parent.verticalCenter
                color: parent.lit ? Qt.rgba(0.06, 0.07, 0.09, 0.12) : modelData.on ? Qt.rgba(Qt.color(l.pal.accent).r, Qt.color(l.pal.accent).g, Qt.color(l.pal.accent).b, 0.18) : Qt.rgba(1, 1, 1, 0.06)
                Text { anchors.centerIn: parent; text: modelData.icon || ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; color: parent.parent.lit ? "#101316" : modelData.on ? l.pal.accent : l.pal.fg }
            }
            Column {
                anchors.left: ic.right; anchors.leftMargin: 14; anchors.right: m.left; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                Text { width: parent.width; elide: Text.ElideRight; text: modelData.title || ""; color: parent.parent.lit ? "#101316" : l.pal.fg; font.family: "Geist"; font.pixelSize: 15; font.weight: Font.Medium }
                Text { visible: !!modelData.desc; width: parent.width; elide: Text.ElideRight; text: modelData.desc || ""; color: parent.parent.lit ? Qt.rgba(0.06, 0.07, 0.09, 0.6) : l.pal.dim; font.family: "Geist"; font.pixelSize: 12 }
            }
            Text { id: m; anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: modelData.meta || ""
                color: parent.lit ? Qt.rgba(0.06, 0.07, 0.09, 0.65) : l.pal.dim; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
            MouseArea { anchors.fill: parent; onClicked: l.picked(index) }
        }
    }
}
