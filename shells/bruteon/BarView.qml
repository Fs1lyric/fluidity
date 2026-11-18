// Bruteon's top: three floating cards (laid out on a 1366 px design, scaled to the screen).
//   left: power, app shortcuts, the Tasks button   centre: the music card (click to grow / shrink)
//   right: volume / bluetooth / wi-fi, the clock, notifications
import QtQuick
import "Pal.js" as P

Item {
    id: b
    property var sys
    property bool bigMusic: false
    property bool widgets: true
    property var apps: [[0xf018d, "terminal"], [0xf0493, "settings"], [0xf05a3, "url:https://web.whatsapp.com"], [0xf024b, "files"],
                        [0xf04c7, "exec:spotify || spotify-launcher"], [0xf0493, "settings"]]
    signal act(string what, var arg)
    signal toggleWidgets()
    signal dashboard()
    readonly property real s: width / 1366
    readonly property alias leftCard: lc
    readonly property alias midCard: mc
    readonly property alias rightCard: rc
    implicitHeight: 150

    Item {
        width: 1366; height: 150; scale: b.s; transformOrigin: Item.TopLeft

        Card {
            id: lc; x: 12; y: 8; width: row.width + 24; height: 34; r: 8; drop: 4
            Row { id: row; x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                Chip { fill: P.orange; glyph: P.g(0xf0425); size: 24; onClicked: b.act("power", null) }
                Repeater { model: b.apps
                    Item { required property var modelData; required property int index; width: 18; height: 24; anchors.verticalCenter: parent.verticalCenter
                        Rectangle { anchors.centerIn: parent; width: 22; height: 22; radius: 11; visible: index === 4; color: P.orange; border.color: P.ink; border.width: 2 }
                        Text { anchors.centerIn: parent; text: P.g(modelData[0]); color: P.ink; font.family: P.mono; font.pixelSize: 12 }
                        Rectangle { anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: -3 } width: 8; height: 2; color: P.ink; visible: index < 4 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { const w = modelData[1]; if (w.startsWith("url:")) b.act("url", w.slice(4)); else if (w.startsWith("exec:")) b.act("exec", ["bash", "-c", w.slice(5)]); else b.act(w, null) } } } }
                Chip { fill: P.green; glyph: P.g(0xf0135); label: "Tasks"; size: 24; onClicked: b.toggleWidgets() }
            }
        }

        Card {
            id: mc
            anchors.horizontalCenter: parent.horizontalCenter; y: 8
            width: b.bigMusic ? 310 : mini.width + 24; height: b.bigMusic ? 130 : 34; r: 10; drop: 4
            Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Row { id: mini; visible: !b.bigMusic; x: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                Chip { fill: P.red; glyph: P.g(0xf0156); size: 22; onClicked: b.act("close", null) }
                Rectangle { width: 2; height: 20; color: P.ink; anchors.verticalCenter: parent.verticalCenter }
                Text { text: b.sys?.hasPlayer ? (b.sys.track || "Unknown") : "Nothing playing"; color: P.ink; font.family: P.mono; font.pixelSize: 11; font.weight: Font.Bold
                       anchors.verticalCenter: parent.verticalCenter; width: Math.min(implicitWidth, 160); elide: Text.ElideRight }
                Repeater { model: [[0xf04ae, "prev"], [b.sys?.playing ? 0xf03e4 : 0xf040a, "play"], [0xf04ad, "next"]]
                    Text { required property var modelData; text: P.g(modelData[0]); color: P.ink; font.family: P.mono; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter
                           MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: b.act(parent.modelData[1], null) } } }
            }
            Item { visible: b.bigMusic; anchors.fill: parent
                Rectangle { x: 12; y: 12; width: 88; height: 88; radius: 8; color: P.lav; border.color: P.ink; border.width: 2; clip: true
                    Image { anchors.fill: parent; anchors.margins: 2; source: b.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop }
                    Text { anchors.centerIn: parent; visible: !(b.sys?.art); text: P.g(0xf075a); font.family: P.mono; font.pixelSize: 30; color: P.ink } }
                Column { x: 112; y: 14; spacing: 3; width: parent.width - 124
                    Text { width: parent.width; text: b.sys?.track || "Nothing playing"; color: P.ink; font.family: P.mono; font.pixelSize: 12; elide: Text.ElideRight }
                    Text { width: parent.width; text: b.sys?.artist ?? ""; color: P.dim; font.family: P.mono; font.pixelSize: 10; elide: Text.ElideRight }
                    Row { spacing: 2; topPadding: 8
                        Repeater { model: 22
                            Rectangle { required property int index; width: 6; radius: 3; anchors.verticalCenter: parent.verticalCenter
                                        height: 4 + Math.abs(Math.sin(index * 1.9)) * 8
                                        color: index / 22 <= (b.sys?.length ? b.sys.position / b.sys.length : 0) ? P.ink : "#c9bdb3" } } } }
                Row { x: 112; y: 88; spacing: 10
                    Text { text: P.mmss(b.sys?.position ?? 0); color: P.ink; font.family: P.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                    Chip { glyph: P.g(0xf04ae); size: 24; onClicked: b.act("prev", null) }
                    Chip { glyph: P.g(b.sys?.playing ? 0xf03e4 : 0xf040a); fill: P.orange; size: 28; onClicked: b.act("play", null) }
                    Chip { glyph: P.g(0xf04ad); size: 24; onClicked: b.act("next", null) }
                    Text { text: P.mmss(b.sys?.length ?? 0); color: P.ink; font.family: P.mono; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter } }
            }
            MouseArea { anchors.fill: parent; z: -1; onClicked: b.bigMusic = !b.bigMusic }
        }

        Card {
            id: rc; x: 1366 - width - 16; y: 8; width: rrow.width + 24; height: 34; r: 8; drop: 4
            Row { id: rrow; x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                Rectangle { width: st.width + 18; height: 24; radius: 6; color: P.paper2; border.color: P.ink; border.width: 2
                    Row { id: st; anchors.centerIn: parent; spacing: 12
                        Repeater { model: [[b.sys?.muted ? 0xf075f : 0xf057e, "mute"], [b.sys?.btOn ? 0xf00af : 0xf00b2, "bt"], [b.sys?.online ? 0xf05a9 : 0xf05aa, "wifi"]]
                            Text { required property var modelData; text: P.g(modelData[0]); color: P.ink; font.family: P.mono; font.pixelSize: 12
                                   MouseArea { anchors.fill: parent; anchors.margins: -5; onClicked: b.act(parent.modelData[1], null)
                                               onWheel: w => { if (parent.modelData[1] === "mute") b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } } } } } }
                Chip { fill: P.lav; glyph: P.g(0xf0954); label: Qt.formatDateTime(b.sys?.now ?? new Date(), "h:mm AP")
                       size: 24; onClicked: b.dashboard() }
                Chip { fill: P.pink; glyph: P.g(0xf009a); size: 24; onClicked: b.act("dnd", null) }
            }
        }
    }
}
