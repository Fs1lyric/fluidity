import QtQuick

// The optional desktop widgets (fluidity-widgets add/remove NAME): a column top-left (you, GitHub, notes,
// text, image) and one top-right (weather, timer, AI usage, battery, visualizer). Pure view; DesktopView holds it.
Item {
    id: dw
    property var pal: ({})
    property bool animate: true
    property var shown: []
    property var w: ({})
    readonly property string sans: "Geist"
    readonly property string serif: "Instrument Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"
    function on(n) { return shown.includes(n) }
    function alpha(c, a) { const q = Qt.color(c || "#ffffff"); return Qt.rgba(q.r, q.g, q.b, a) }
    component Label: Text { color: dw.pal.dim; font.family: dw.mono; font.pixelSize: 11; font.letterSpacing: 2.2 }

    Column {
        x: 44; y: 84; spacing: 14; width: 420
        Glass { // you
            visible: dw.on("user"); pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 92
            Rectangle { x: 18; width: 56; height: 56; radius: 28; anchors.verticalCenter: parent.verticalCenter; clip: true
                gradient: Gradient { GradientStop { position: 0; color: dw.pal.accent } GradientStop { position: 1; color: dw.pal.cyan } }
                Text { anchors.centerIn: parent; text: ((dw.w.user || {}).name || "?")[0].toUpperCase(); color: "#101316"; font.family: dw.serif; font.italic: true; font.pixelSize: 30 }
                Image { anchors.fill: parent; source: (dw.w.user || {}).face || ""; visible: !!(dw.w.user || {}).face; fillMode: Image.PreserveAspectCrop } }
            Column { x: 90; anchors.verticalCenter: parent.verticalCenter
                Text { text: (dw.w.user || {}).name || ""; color: dw.pal.fg; font.family: dw.serif; font.italic: true; font.pixelSize: 26 }
                Text { text: "@" + ((dw.w.user || {}).host || "") + " · up " + ((dw.w.user || {}).uptime || ""); color: dw.pal.dim; font.family: dw.mono; font.pixelSize: 12 } }
        }
        Glass { // github contributions
            visible: dw.on("github") && ((dw.w.github || {}).weeks || []).length > 0; pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 150
            Label { x: 20; y: 18; text: "GITHUB · " + ((dw.w.github || {}).total || 0) + " THIS YEAR" }
            Row {
                x: 20; y: 44; spacing: 2
                Repeater { model: ((dw.w.github || {}).weeks || []).slice(-53)
                    Column { spacing: 2
                        Repeater { model: modelData
                            Rectangle { width: 5; height: 11; radius: 2; color: modelData < 0 ? "transparent" : modelData === 0 ? Qt.rgba(1, 1, 1, 0.06) : dw.alpha(dw.pal.accent, 0.25 + 0.75 * modelData / 4) } } } }
            }
        }
        Glass { // notes
            visible: dw.on("notes"); pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: nc.height + 36
            Column { id: nc; x: 20; y: 18; width: parent.width - 40; spacing: 6
                Label { text: "NOTES · ~/.local/share/fluidity/notes.md" }
                Repeater { model: (dw.w.notes || []).slice(0, 10)
                    Text { width: parent.width; elide: Text.ElideRight; text: modelData.replace(/^#+\s*/, "").replace(/^- /, "·  ")
                        color: /^#/.test(modelData) ? dw.pal.accent : dw.pal.fg; font.family: /^#/.test(modelData) ? dw.serif : dw.sans; font.italic: /^#/.test(modelData)
                        font.pixelSize: /^#/.test(modelData) ? 20 : 14 } }
                Text { visible: !(dw.w.notes || []).length; text: "Write in notes.md and it shows here."; color: dw.pal.dim; font.family: dw.sans; font.pixelSize: 13 } }
        }
        Text { visible: dw.on("text") && !!dw.w.text; width: parent.width; wrapMode: Text.WordWrap; text: dw.w.text || ""; color: dw.alpha(dw.pal.fg, 0.85); font.family: dw.serif; font.italic: true; font.pixelSize: 34 }
        Glass {
            visible: dw.on("image") && !!dw.w.image; pal: dw.pal; tint: 0.4; radius: 26; width: parent.width; height: 240; clip: true
            Image { anchors.fill: parent; anchors.margins: 6; source: dw.w.image || ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 840 }
        }
    }

    Column {
        anchors.right: parent.right; anchors.rightMargin: 24; y: 84; spacing: 14; width: 300
        Glass { // weather
            visible: dw.on("weather") && !!(dw.w.weather || {}).now; pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 120
            Text { x: 20; y: 14; text: ((dw.w.weather || {}).now || "").split(" ")[0]; color: dw.pal.accent; font.family: dw.mono; font.pixelSize: 40 }
            Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 8; text: ((dw.w.weather || {}).now || "").split(" ").slice(1).join(" "); color: dw.pal.fg; font.family: dw.serif; font.italic: true; font.pixelSize: 56 }
            Text { x: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 16; text: [(dw.w.weather || {}).text, (dw.w.weather || {}).feels].filter(Boolean).join(" · "); color: dw.pal.dim; font.family: dw.sans; font.pixelSize: 13 }
        }
        Glass { // focus timer
            visible: dw.on("timer"); pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 92
            Label { x: 20; y: 16; text: "FOCUS" }
            Text { x: 20; y: 34; text: dw.w.timer ? dw.w.timer.replace(/^focus /, "") : "❖ ; f starts 25"; color: dw.w.timer ? dw.pal.fg : dw.pal.dim
                font.family: dw.w.timer ? dw.serif : dw.sans; font.italic: !!dw.w.timer; font.pixelSize: dw.w.timer ? 40 : 14 }
        }
        Glass { // AI usage
            visible: dw.on("usage") && ((dw.w.usage || {}).percent ?? -1) >= 0; pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 80
            Label { x: 20; y: 16; text: ((dw.w.usage || {}).name || "ai").toUpperCase() + " USAGE" }
            Rectangle { x: 20; y: 44; width: parent.width - 100; height: 10; radius: 5; color: Qt.rgba(1, 1, 1, 0.07)
                Grad { pal: dw.pal; height: 10; radius: 5; width: parent.width * Math.min(1, ((dw.w.usage || {}).percent || 0) / 100) } }
            Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 30; text: ((dw.w.usage || {}).percent || 0) + "%"; color: dw.pal.fg; font.family: dw.serif; font.italic: true; font.pixelSize: 28 }
        }
        Glass { // battery
            visible: dw.on("battery") && ((dw.w.battery || {}).percent ?? -1) >= 0; pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 80
            Label { x: 20; y: 16; text: (dw.w.battery || {}).charging ? "BATTERY · CHARGING" : "BATTERY" }
            Rectangle { x: 20; y: 44; width: parent.width - 100; height: 10; radius: 5; color: Qt.rgba(1, 1, 1, 0.07)
                Rectangle { height: 10; radius: 5; width: parent.width * ((dw.w.battery || {}).percent || 0) / 100; color: ((dw.w.battery || {}).percent || 0) <= 15 ? dw.pal.red : dw.pal.accent } }
            Text { anchors.right: parent.right; anchors.rightMargin: 20; y: 30; text: ((dw.w.battery || {}).percent || 0) + "%"; color: dw.pal.fg; font.family: dw.serif; font.italic: true; font.pixelSize: 28 }
        }
        Glass { // visualizer
            visible: dw.on("visualizer") && (dw.w.viz || []).length > 0; pal: dw.pal; tint: 0.66; radius: 26; width: parent.width; height: 90
            Row { x: 18; anchors.bottom: parent.bottom; anchors.bottomMargin: 18; spacing: 3; height: 54
                Repeater { model: dw.w.viz || []
                    Rectangle { width: (300 - 36 - 3 * ((dw.w.viz || []).length - 1)) / Math.max(1, (dw.w.viz || []).length); radius: 2; anchors.bottom: parent.bottom
                        height: Math.max(3, 54 * modelData); color: dw.alpha(index % 3 === 1 ? dw.pal.cyan : dw.pal.accent, 0.4 + 0.6 * modelData) } } }
        }
    }
}
