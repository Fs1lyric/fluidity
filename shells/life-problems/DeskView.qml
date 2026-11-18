// The desktop: the rounded ink frame around the whole screen, the stats + music card (top left), the now-playing
// note (bottom left) and the desktop icons down the right edge. Lives on the bottom layer.
import QtQuick
import "Pal.js" as P

Item {
    id: v
    property var sys
    signal act(string what, var arg)
    readonly property int inset: 30
    // stats card
    Card {
        x: v.inset + 20; y: v.inset + 60; width: 260; height: 380
        Column {
            anchors.horizontalCenter: parent.horizontalCenter; y: 20; spacing: 14
            Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 72; height: 72; radius: 12; color: P.cream; border.color: P.ink; border.width: 4
                        Rectangle { x: 10; y: 10; width: 52; height: 40; radius: 4; color: P.teal; border.color: P.ink; border.width: 3
                                    Text { anchors.centerIn: parent; text: "󰁥"; font.family: P.icon; font.pixelSize: 26; color: P.ink } }
                        Rectangle { x: 18; y: 56; width: 36; height: 6; radius: 3; color: P.ink } }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(v.sys?.now ?? new Date(), "hh:mm AP")
                   font.family: P.mono; font.pixelSize: 30; font.weight: Font.Medium; color: P.ink }
            Item { width: vol.width; height: vol.height
                   Meter { id: vol; label: "vol"; value: v.sys?.volume ?? 0; fill: P.teal }
                   MouseArea { anchors.fill: parent; onWheel: w => v.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05); onClicked: v.act("mute", null) } }
            Meter { label: "cpu"; value: v.sys?.cpu ?? 0; fill: P.mint }
            Meter { label: "ram"; value: v.sys?.ram ?? 0; fill: P.salmon }
            Row {
                spacing: 10; topPadding: 8
                Rectangle { width: 52; height: 52; color: P.ink; clip: true
                            Image { anchors.fill: parent; source: v.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
                Column { spacing: 8; width: 150
                         Text { width: parent.width; elide: Text.ElideRight; text: v.sys?.hasPlayer ? v.sys.track : "Nothing playing"; font.family: P.mono; font.pixelSize: 13; color: P.ink }
                         Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 18
                               Repeater { model: [["󰒮", "prev"], [v.sys?.playing ? "󰏤" : "󰐊", "play"], ["󰒭", "next"]]
                                          Text { required property var modelData; text: modelData[0]; font.family: P.icon; font.pixelSize: 18; color: P.ink
                                                 MouseArea { anchors.fill: parent; onClicked: v.act(parent.modelData[1], null) } } } } }
            }
        }
    }
    // the now-playing note
    Card {
        visible: v.sys?.hasPlayer ?? false
        x: v.inset + 4; y: v.height - v.inset - 104; width: 300; height: 92; shadow: 0
        Text { x: 22; y: 14; width: parent.width - 40; lineHeight: 1.1; font.family: P.mono; font.pixelSize: 12; color: P.ink; wrapMode: Text.Wrap; maximumLineCount: 5
               text: (v.sys?.track ?? "") + "\n" + (v.sys?.artist ?? "") }
    }
    // desktop icons
    Column {
        x: v.width - v.inset - 120; y: v.inset + 70; spacing: 26; width: 100
        Repeater {
            model: [["󰇄", "Desktop", ["bash", "-c", "xdg-open ~/Desktop || xdg-open ~"]], ["󰉍", "Downloads", ["bash", "-c", "xdg-open ~/Downloads"]],
                    ["󰖟", "Internet", ["xdg-open", "https://"]]]
            Column {
                required property var modelData
                width: 100; spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.modelData[0]; font.family: P.icon; font.pixelSize: 56; color: P.ink }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.modelData[1]; font.family: P.mono; font.pixelSize: 13; font.weight: Font.Medium; color: P.ink }
                TapHandler { onDoubleTapped: v.act("exec", parent.modelData[2]) }
            }
        }
    }
    Column {
        x: v.width - v.inset - 120; y: v.height - v.inset - 130; width: 100; spacing: 4
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰩹"; font.family: P.icon; font.pixelSize: 56; color: P.ink }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "My Life"; font.family: P.mono; font.pixelSize: 13; font.weight: Font.Medium; color: P.ink }
        TapHandler { onDoubleTapped: v.act("exec", ["bash", "-c", "xdg-open ~"]) }
    }
}
