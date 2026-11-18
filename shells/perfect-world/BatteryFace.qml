// elenapan's cute battery face (noodle/cute_battery_face.lua): a 100x50 pill that fills with the charge,
// green and smiling above 45 %, pink and flat below, red and frowning when low, cyan with a bolt when charging.
import QtQuick
import "Pal.js" as P

Item {
    id: f
    property real level: 0.5
    property bool charging: false
    readonly property color tone: charging ? P.c6 : level >= 0.45 ? P.c2 : level >= 0.15 ? P.c3 : P.c1
    readonly property string mood: charging || level >= 0.45 ? "smile" : level >= 0.15 ? "ok" : "frown"
    implicitWidth: 100; implicitHeight: 50

    Rectangle {
        anchors.fill: parent; radius: 9; clip: true
        color: Qt.rgba(f.tone.r, f.tone.g, f.tone.b, 0.33)
        Rectangle { width: parent.width * Math.max(0, Math.min(1, f.level)); height: parent.height; color: f.tone
                    Behavior on width { NumberAnimation { duration: 400 } } }
    }
    Row {
        anchors.centerIn: parent
        spacing: 7
        Rectangle { width: 5; height: 5; radius: 2.5; color: P.bg; anchors.verticalCenter: parent.verticalCenter }
        Item {
            width: 10; height: 10; anchors.verticalCenter: parent.verticalCenter
            // smile: bottom half disc; frown: top half disc; ok: a flat dash
            Rectangle { visible: f.mood !== "ok"; width: 10; height: 10; radius: 5; color: P.bg
                        y: f.mood === "smile" ? -5 : 4
                        layer.enabled: true }
            Rectangle { visible: f.mood === "smile"; x: -1; y: -6; width: 12; height: 6; color: f.tone }
            Rectangle { visible: f.mood === "frown"; x: -1; y: 9; width: 12; height: 6; color: f.tone }
            Rectangle { visible: f.mood === "ok"; y: 4; width: 10; height: 3; radius: 1.5; color: P.bg }
        }
        Rectangle { width: 5; height: 5; radius: 2.5; color: P.bg; anchors.verticalCenter: parent.verticalCenter }
    }
    Text {
        visible: f.charging
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        text: P.g(P.glyph.bolt); font.family: P.icons; font.pixelSize: 17
        color: Qt.rgba(0.1, 0.125, 0.15, 0.5)
    }
}
