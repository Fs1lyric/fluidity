// Bruteon's dashboard (preview 2): profile, app list, clock, weather + line of the day, volume / brightness
// sliders, system specs, music, CPU / RAM / disk and link buttons, all inside one big card. 1366 x 768 design.
import QtQuick
import "Pal.js" as P

Item {
    id: d
    property var sys
    property real brightness: 0.49
    signal act(string what, var arg)
    signal close()
    readonly property real s: width / 1366
    function line() {
        const h = (d.sys?.now ?? new Date()).getHours();
        return h < 5 ? "A quiet night, perfect for a little more code." : h < 12 ? "A fresh morning, perfect for a clean build."
             : h < 17 ? "A steady afternoon, perfect for shipping." : "A peaceful evening, perfect for compiling.";
    }
    MouseArea { anchors.fill: parent; onClicked: d.close() }

    Item {
        width: 1366; height: 768; scale: d.s; transformOrigin: Item.TopLeft
        Card {
            x: 213; y: 103; width: 676; height: 412; r: 12; drop: 6
            MouseArea { anchors.fill: parent }

            Card { x: 15; y: 14; width: 135; height: 152; fill: P.paper2; line: 2; drop: 4
                Card { anchors.horizontalCenter: parent.horizontalCenter; y: 12; width: 58; height: 58; r: 8; line: 2; drop: 3; fill: "#e8dccd"
                    Text { anchors.centerIn: parent; text: P.g(0xf0004); font.family: P.mono; font.pixelSize: 30; color: P.ink } }
                Column { anchors.horizontalCenter: parent.horizontalCenter; y: 82; spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: d.sys?.user ?? ""; color: P.ink; font.family: P.mono; font.pixelSize: 13; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: (d.sys?.user ?? "") + "@" + (d.sys?.host ?? ""); color: P.ink; font.family: P.mono; font.pixelSize: 8 }
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 50; height: 14; radius: 7; color: P.green; border.color: P.ink; border.width: 1.5
                        Text { anchors.centerIn: parent; text: "● " + (d.sys?.online ? "Online" : "Offline"); font.family: P.mono; font.pixelSize: 7; color: P.ink } } } }

            Card { x: 15; y: 178; width: 135; height: 220; fill: P.paper2; line: 2; drop: 4
                Column { x: 10; y: 10; spacing: 8
                    Repeater { model: [[0xf0239, "#e8613c", "Firefox", "browser"], [0xf018d, "#4a8a3c", "Terminal", "terminal"], [0xf024b, "#d9a43c", "Files", "files"],
                                       [0xf04c7, "#3caa5a", "Spotify", "exec:spotify || spotify-launcher"], [0xf03eb, "#3c6ad9", "Editor", "exec:ghostty -e nvim"],
                                       [0xf066f, "#7a5ad9", "Discord", "exec:vesktop"]]
                        Card { required property var modelData; width: 115; height: 26; r: 6; line: 2; drop: 2; fill: P.paper
                            Text { x: 10; anchors.verticalCenter: parent.verticalCenter; text: P.g(modelData[0]); color: modelData[1]; font.family: P.mono; font.pixelSize: 12 }
                            Text { x: 30; anchors.verticalCenter: parent.verticalCenter; text: modelData[2]; color: P.ink; font.family: P.mono; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { const w = parent.modelData[3]; w.startsWith("exec:") ? d.act("exec", ["bash", "-c", w.slice(5)]) : d.act(w, null); d.close() } } } } } }

            Card { x: 162; y: 14; width: 200; height: 62; fill: P.paper2; line: 2; drop: 4
                Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: Qt.formatDateTime(d.sys?.now ?? new Date(), "hh : mm AP").slice(0, 7); color: P.ink; font.family: P.mono; font.pixelSize: 24 }
                Text { x: 103; y: 36; text: Qt.formatDateTime(d.sys?.now ?? new Date(), "AP"); color: P.dim; font.family: P.mono; font.pixelSize: 7 }
                Rectangle { x: 118; y: 12; width: 2; height: 38; color: "#c9bdb3" }
                Column { x: 126; anchors.verticalCenter: parent.verticalCenter
                    Text { text: Qt.formatDateTime(d.sys?.now ?? new Date(), "dddd").toUpperCase(); color: P.ink; font.family: P.mono; font.pixelSize: 9; font.bold: true }
                    Text { text: Qt.formatDateTime(d.sys?.now ?? new Date(), "MMMM d, yyyy"); color: P.ink; font.family: P.mono; font.pixelSize: 8 } } }

            Card { x: 162; y: 88; width: 200; height: 108; fill: P.paper2; line: 2; drop: 4
                Card { x: 8; y: 8; width: 130; height: 40; r: 6; line: 2; drop: 2
                    Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: (d.sys?.weatherTemp || "--") + "°C"; color: P.ink; font.family: P.mono; font.pixelSize: 16 }
                    Rectangle { x: 62; y: 8; width: 2; height: 24; color: "#c9bdb3" }
                    Text { x: 70; anchors.verticalCenter: parent.verticalCenter; width: 56; text: d.sys?.weatherCond || ""; color: P.ink; font.family: P.mono; font.pixelSize: 8; font.bold: true; elide: Text.ElideRight } }
                Card { x: 146; y: 8; width: 44; height: 40; r: 6; line: 2; drop: 2
                    Text { anchors.centerIn: parent; text: P.g(d.sys?.night ? 0xf0594 : 0xf0599); font.family: P.mono; font.pixelSize: 18; color: P.ink } }
                Card { x: 8; y: 56; width: 182; height: 42; r: 6; line: 2; drop: 2
                    Text { x: 8; y: 6; width: 166; wrapMode: Text.WordWrap; text: "“ " + d.line(); color: P.ink; font.family: P.mono; font.pixelSize: 8 } } }

            Card { x: 372; y: 14; width: 75; height: 182; fill: P.paper2; line: 2; drop: 4
                Repeater { model: [[0, P.red, 0xf057e, "volume"], [1, P.green, 0xf00df, "brightness"]]
                    Item { required property var modelData; x: 8 + modelData[0] * 34; y: 8; width: 26; height: 166
                        readonly property real val: modelData[3] === "volume" ? (d.sys?.volume ?? 0) : d.brightness
                        Chip { size: 20; fill: modelData[0] ? P.green : P.red; glyph: P.g(modelData[2]); onClicked: modelData[3] === "volume" ? d.act("mute", null) : 0 }
                        Rectangle { y: 28; width: 22; height: 96; radius: 11; color: P.paper; border.color: P.ink; border.width: 2; clip: true
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: parent.height * parent.parent.val; radius: 11; color: parent.parent.modelData[1]; border.color: P.ink; border.width: 2 }
                            MouseArea { anchors.fill: parent
                                function set(m) { const v = Math.max(0, Math.min(1, 1 - m.y / height)); if (parent.parent.modelData[3] === "volume") d.act("volume", v); else { d.brightness = v; d.act("brightness", v) } }
                                onPressed: m => set(m); onPositionChanged: m => set(m) } }
                        Rectangle { y: 134; x: -2; width: 26; height: 14; radius: 3; color: parent.modelData[1]; border.color: P.ink; border.width: 1.5
                            Text { anchors.centerIn: parent; text: Math.round(parent.parent.val * 100) + "%"; font.family: P.mono; font.pixelSize: 7; color: P.ink } } } } }

            Card { x: 456; y: 14; width: 204; height: 182; fill: P.paper2; line: 2; drop: 4
                Text { x: 10; y: 10; text: P.g(0xf0379) + "  System Specs"; color: P.ink; font.family: P.mono; font.pixelSize: 10; font.bold: true }
                Rectangle { x: 10; y: 30; width: 184; height: 1.5; color: "#c9bdb3" }
                Grid { x: 10; y: 40; columns: 2; spacing: 6
                    Repeater { model: [[0xf08c7, P.orange, "OS", "Arch Linux"], [0xf05b2, P.blue, "WM", "Hyprland"], [0xf018d, P.green, "Shell", "zsh"],
                                       [0xf0379, P.red, "Host", d.sys?.host ?? ""], [0xf0150, P.lav, "Uptime", (d.sys?.uptime ?? "").replace(/ hours?,?/, "H").replace(/ minutes?/, "M").replace(/ days?,?/, "D")],
                                       [0xf03d7, P.green, "Packages", String(d.sys?.packages ?? 0)]]
                        Card { required property var modelData; width: 89; height: 38; r: 5; line: 2; drop: 2; fill: P.paper
                            Rectangle { x: 6; anchors.verticalCenter: parent.verticalCenter; width: 18; height: 18; radius: 4; color: modelData[1]; border.color: P.ink; border.width: 1.5
                                Text { anchors.centerIn: parent; text: P.g(parent.parent.modelData[0]); font.family: P.mono; font.pixelSize: 9; color: P.ink } }
                            Column { x: 30; anchors.verticalCenter: parent.verticalCenter
                                Text { text: modelData[2]; color: P.dim; font.family: P.mono; font.pixelSize: 6 }
                                Text { text: modelData[3]; color: P.ink; font.family: P.mono; font.pixelSize: 8; width: 54; elide: Text.ElideRight } } } } } }

            Card { x: 162; y: 210; width: 350; height: 112; fill: P.paper2; line: 2; drop: 4
                Rectangle { x: 10; y: 10; width: 90; height: 90; radius: 6; color: P.lav; border.color: P.ink; border.width: 2; clip: true
                    Image { anchors.fill: parent; anchors.margins: 2; source: d.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop }
                    Text { anchors.centerIn: parent; visible: !(d.sys?.art); text: P.g(0xf075a); font.family: P.mono; font.pixelSize: 30; color: P.ink } }
                Column { x: 112; y: 14; spacing: 4
                    Text { text: d.sys?.track || "Nothing playing"; color: P.ink; font.family: P.mono; font.pixelSize: 12; width: 228; elide: Text.ElideRight }
                    Text { text: d.sys?.artist ?? ""; color: P.dim; font.family: P.mono; font.pixelSize: 8 }
                    Row { spacing: 3; topPadding: 4
                        Repeater { model: 20; Rectangle { required property int index; width: 9; height: 9; radius: 5
                            color: index / 20 <= (d.sys?.length ? d.sys.position / d.sys.length : 0) ? [P.yellow, "#e6b93c", P.green, P.blue, P.lav][Math.floor(index / 4)] : "#f3cfd6" } } } }
                Row { x: 112; y: 74; spacing: 12
                    Text { text: P.mmss(d.sys?.position ?? 0); color: P.ink; font.family: P.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                    Chip { glyph: P.g(0xf04ae); size: 22; onClicked: d.act("prev", null) }
                    Chip { glyph: P.g(d.sys?.playing ? 0xf03e4 : 0xf040a); fill: P.orange; size: 26; onClicked: d.act("play", null) }
                    Chip { glyph: P.g(0xf04ad); size: 22; onClicked: d.act("next", null) }
                    Text { text: P.mmss(d.sys?.length ?? 0); color: P.ink; font.family: P.mono; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter } } }

            Card { x: 522; y: 210; width: 138; height: 112; fill: P.paper2; line: 2; drop: 4
                Column { x: 8; y: 10; spacing: 8
                    Repeater { model: [[0xf0ee0, P.red, "CPU", d.sys?.cpu ?? 0], [0xf035b, P.blue, "RAM", d.sys?.ram ?? 0], [0xf02ca, P.green, "Disk", d.sys?.diskUsed ?? 0]]
                        Card { required property var modelData; width: 122; height: 26; r: 5; line: 2; drop: 2; fill: P.paper
                            Rectangle { x: 5; anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; radius: 3; color: modelData[1]; border.color: P.ink; border.width: 1.5
                                Text { anchors.centerIn: parent; text: P.g(parent.parent.modelData[0]); font.family: P.mono; font.pixelSize: 8; color: P.ink } }
                            Text { x: 26; anchors.verticalCenter: parent.verticalCenter; text: modelData[2]; color: P.ink; font.family: P.mono; font.pixelSize: 8; font.bold: true }
                            Rectangle { x: 50; anchors.verticalCenter: parent.verticalCenter; width: 40; height: 7; radius: 3.5; color: P.paper2; border.color: P.ink; border.width: 1
                                Rectangle { width: parent.width * parent.parent.modelData[3]; height: parent.height; radius: 3.5; color: parent.parent.modelData[1] } }
                            Text { x: 96; anchors.verticalCenter: parent.verticalCenter; text: Math.round(modelData[3] * 100) + "%"; color: P.ink; font.family: P.mono; font.pixelSize: 8; font.bold: true } } } } }

            Card { x: 162; y: 332; width: 498; height: 66; fill: P.paper2; line: 2; drop: 4
                Row { anchors.centerIn: parent; spacing: 10
                    Repeater { model: [[0xf02a4, "#e2ddd8", "GitHub", "https://github.com"], [0xf044d, "#f6a37f", "Reddit", "https://reddit.com"],
                                       [0xf05c3, "#f28b82", "YouTube", "https://youtube.com"], [0xf05a3, "#b8e3a3", "WhatsApp", "https://web.whatsapp.com"],
                                       [0xf01ee, "#f8c3d2", "Gmail", "https://mail.google.com"], [0xf0543, "#d9bdf5", "Twitch", "https://twitch.tv"]]
                        Card { required property var modelData; width: 70; height: 44; r: 6; line: 2; drop: 3; fill: modelData[1]
                            Column { anchors.centerIn: parent; spacing: 2
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: P.g(parent.parent.modelData[0]); font.family: P.mono; font.pixelSize: 13; color: P.ink }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.modelData[2]; font.family: P.mono; font.pixelSize: 8; font.bold: true; color: P.ink } }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { d.act("url", parent.modelData[3]); d.close() } } } } } }
        }
    }
}
