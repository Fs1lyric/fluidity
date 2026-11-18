import QtQuick

// Media: the cover, the song, a seek bar, prev / play / next, the live visualizer (cava) and synced lyrics
// (lrclib.net). Keys: space play, ← → seek, ↑ ↓ / tab pick a button, ↵ press it, n p next / previous, l lyrics.
AppBase {
    id: a
    readonly property bool has: !!d.title
    readonly property var buttons: [{ icon: "󰒮", label: "previous" }, { icon: d.playing ? "󰏤" : "󰐊", label: d.playing ? "pause" : "play" },
                                    { icon: "󰒭", label: "next" }, { icon: "󰒟", label: "shuffle", on: !!d.shuffle }, { icon: "󰑖", label: "repeat", on: !!d.loop },
                                    { icon: "󰍡", label: "lyrics", on: !!d.showLyrics }]

    Text { visible: !a.has; anchors.centerIn: parent; text: "Nothing playing.  ↵ opens Spotify"; color: a.pal.dim; font.family: a.sans; font.pixelSize: 15 }

    Rectangle { // the cover
        visible: a.has
        x: 22; y: 22; width: 200; height: 200; radius: 26; clip: true
        gradient: Gradient { GradientStop { position: 0; color: a.alpha(a.pal.accent, 0.5) } GradientStop { position: 1; color: a.alpha(a.pal.cyan, 0.18) } }
        Text { anchors.centerIn: parent; visible: !a.d.art; text: "󰝚"; font.family: a.mono; font.pixelSize: 64; color: a.ink; opacity: 0.6 }
        Image { anchors.fill: parent; source: a.d.art || ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 400; visible: !!a.d.art }
    }

    Column {
        visible: a.has
        x: 248; y: 26; width: (a.d.lyrics || []).length ? 380 : parent.width - 270; spacing: 6
        Text { text: (a.d.player || "").toUpperCase(); color: a.pal.dim; font.family: a.mono; font.pixelSize: 11; font.letterSpacing: 2 }
        Text { width: parent.width; elide: Text.ElideRight; text: a.d.title || ""; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 38 }
        Text { width: parent.width; elide: Text.ElideRight; text: [a.d.artist, a.d.album].filter(Boolean).join(" · "); color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
        Item { width: 1; height: 14 }
        Rectangle {
            width: parent.width; height: 6; radius: 3; color: a.faint
            Grad { pal: a.pal; height: 6; radius: 3; width: parent.width * Math.max(0, Math.min(1, a.d.progress || 0)) }
            Rectangle { width: 14; height: 14; radius: 7; color: a.pal.fg; anchors.verticalCenter: parent.verticalCenter; x: parent.width * Math.max(0, Math.min(1, a.d.progress || 0)) - 7 }
        }
        Item { width: parent.width; height: 18
            Text { text: a.d.position || ""; color: a.pal.dim; font.family: a.mono; font.pixelSize: 11 }
            Text { anchors.right: parent.right; text: a.d.length || ""; color: a.pal.dim; font.family: a.mono; font.pixelSize: 11 } }
        Row {
            spacing: 8
            Repeater {
                model: a.buttons
                Rectangle {
                    readonly property bool lit: index === a.sel
                    width: index === 1 ? 56 : 42; height: 42; radius: 21; anchors.verticalCenter: parent.verticalCenter
                    color: lit ? "transparent" : modelData.on ? a.alpha(a.pal.accent, 0.2) : a.faint
                    Grad { anchors.fill: parent; radius: 21; pal: a.pal; visible: parent.lit }
                    Text { anchors.centerIn: parent; text: modelData.icon; font.family: a.mono; font.pixelSize: index === 1 ? 22 : 17; color: parent.lit ? a.ink : modelData.on ? a.pal.accent : a.pal.fg }
                    MouseArea { anchors.fill: parent; onClicked: a.picked(index) }
                }
            }
        }
    }

    Column { // lyrics: the line before, the line now, the next two
        visible: a.has && (a.d.lyrics || []).length > 0
        x: 652; y: 40; width: parent.width - 652 - 24; spacing: 10
        Repeater {
            model: a.d.lyrics || []
            Text { width: parent.width; wrapMode: Text.WordWrap; text: modelData; font.family: index === a.d.lyric ? a.serif : a.sans; font.italic: index === a.d.lyric
                font.pixelSize: index === a.d.lyric ? 24 : 14; color: index === a.d.lyric ? a.pal.accent : a.alpha(a.pal.fg, 0.45) }
        }
    }

    Row { // the visualizer
        visible: a.has
        x: 22; anchors.bottom: parent.bottom; anchors.bottomMargin: 18; spacing: 4; height: 44
        Repeater {
            model: a.d.bars || []
            Rectangle {
                width: ((a.width - 44) - 4 * ((a.d.bars || []).length - 1)) / Math.max(1, (a.d.bars || []).length)
                height: Math.max(3, 44 * modelData); radius: 2; anchors.bottom: parent.bottom
                color: a.alpha(index % 3 === 1 ? a.pal.cyan : a.pal.accent, 0.35 + 0.6 * modelData)
                Behavior on height { enabled: a.animate; NumberAnimation { duration: 70 } }
            }
        }
    }
}
