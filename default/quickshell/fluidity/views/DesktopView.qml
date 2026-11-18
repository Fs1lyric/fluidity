import QtQuick

// The desktop under the windows: a huge italic serif clock with a glowing accent colon, and three cards
// (now playing, today from Calendio, system rings). Pure view for tools/render.py.
Item {
    id: desk
    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", blue: "#a9b8e8", red: "#f2a7a7", fg: "#e3e4da", dim: "#878880", muted: "#3a3f45", yellow: "#e8d98a", magenta: "#c8a8e0" })
    property bool animate: true
    property string hours: "09"
    property string minutes: "41"
    property string weekday: "Wednesday"
    property string date: "18 November"
    property string motto: "// stay fluid."
    property var media: ({ title: "", artist: "", progress: 0, position: "", length: "", playing: false, art: "" })
    property var agenda: []     // [{time, title, sub, color, now, done}]
    property var sys: ({ cpu: 0, ram: 0, temp: 0, disk: 0 })
    readonly property string sans: "Geist"
    readonly property string serif: "Instrument Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"

    // ---- clock ----
    Column {
        x: 44; anchors.bottom: parent.bottom; anchors.bottomMargin: 60
        Row {
            Text { text: desk.hours; color: "#eef0e4"; font.family: desk.serif; font.italic: true; font.pixelSize: 210; font.letterSpacing: -4 }
            Text {
                text: ":"; color: desk.pal.accent; font.family: desk.serif; font.italic: true; font.pixelSize: 210
                SequentialAnimation on opacity { running: desk.animate; loops: Animation.Infinite; PauseAnimation { duration: 1000 } NumberAnimation { to: 0.25; duration: 300 } PauseAnimation { duration: 700 } NumberAnimation { to: 1; duration: 300 } }
            }
            Text { text: desk.minutes; color: "#eef0e4"; font.family: desk.serif; font.italic: true; font.pixelSize: 210; font.letterSpacing: -4 }
        }
        Row {
            leftPadding: 8; spacing: 8
            Text { text: desk.weekday + ","; color: Qt.rgba(0.89, 0.89, 0.85, 0.85); font.family: desk.serif; font.pixelSize: 26 }
            Text { text: desk.date; color: desk.pal.accent; font.family: desk.serif; font.italic: true; font.pixelSize: 26 }
        }
        Text { leftPadding: 10; topPadding: 12; text: desk.motto; color: Qt.rgba(0.89, 0.89, 0.85, 0.5); font.family: desk.mono; font.pixelSize: 13 }
    }

    Row {
        id: cards
        anchors.right: parent.right; anchors.rightMargin: 24; anchors.bottom: parent.bottom; anchors.bottomMargin: 24
        spacing: 16

        // ---- now playing ----
        Glass {
            pal: desk.pal; tint: 0.66; radius: 28; width: 392; height: 392
            visible: desk.media.title !== ""
            Column {
                anchors.fill: parent; anchors.margins: 24; spacing: 14
                Text { text: "NOW PLAYING"; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11; font.letterSpacing: 2.2 }
                Rectangle {
                    width: parent.width; height: 196; radius: 20; clip: true
                    gradient: Gradient { GradientStop { position: 0; color: desk.pal.red } GradientStop { position: 0.55; color: "#2a2436" } GradientStop { position: 1; color: desk.pal.accent } }
                    Image { anchors.fill: parent; source: desk.media.art || ""; fillMode: Image.PreserveAspectCrop; visible: !!desk.media.art; asynchronous: true }
                    Rectangle {
                        width: 56; height: 56; radius: 28; color: "#121418"; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 16
                        Rectangle { width: 16; height: 16; radius: 8; color: desk.pal.accent; anchors.centerIn: parent }
                        RotationAnimation on rotation { running: desk.animate && desk.media.playing; loops: Animation.Infinite; from: 0; to: 360; duration: 4000 }
                    }
                }
                Column {
                    Text { width: 344; elide: Text.ElideRight; text: desk.media.title; color: desk.pal.fg; font.family: desk.serif; font.italic: true; font.pixelSize: 28 }
                    Text { width: 344; elide: Text.ElideRight; text: desk.media.artist; color: desk.pal.dim; font.family: desk.sans; font.pixelSize: 13 }
                }
                Rectangle {
                    width: parent.width; height: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.08)
                    Grad { pal: desk.pal; radius: 3; height: 6; width: parent.width * desk.media.progress }
                }
                Item { width: parent.width; height: 14
                    Text { text: desk.media.position; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "❖ M"; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11 }
                    Text { anchors.right: parent.right; text: desk.media.length; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11 } }
            }
        }

        // ---- today (Calendio) ----
        Glass {
            pal: desk.pal; tint: 0.66; radius: 28; width: 420; height: 392
            visible: desk.agenda.length > 0
            Column {
                anchors.fill: parent; anchors.margins: 24; spacing: 4
                Item { width: parent.width; height: 28
                    Text { text: "TODAY · CALENDIO"; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11; font.letterSpacing: 2.2 }
                    Text { anchors.right: parent.right; text: "❖ A"; color: desk.pal.accent; font.family: desk.mono; font.pixelSize: 11 } }
                Repeater {
                    model: desk.agenda.slice(0, 5)
                    Rectangle {
                        width: parent.width + 24; x: -12; height: 58; radius: 16
                        color: modelData.now ? Qt.rgba(Qt.color(desk.pal.accent).r, Qt.color(desk.pal.accent).g, Qt.color(desk.pal.accent).b, 0.08) : "transparent"
                        border.width: modelData.now ? 1 : 0; border.color: Qt.rgba(Qt.color(desk.pal.accent).r, Qt.color(desk.pal.accent).g, Qt.color(desk.pal.accent).b, 0.3)
                        Row {
                            x: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 14
                            Text { width: 52; text: modelData.time; color: modelData.now ? desk.pal.accent : desk.pal.dim; font.family: desk.mono; font.pixelSize: 12 }
                            Rectangle { width: 4; height: 38; radius: 2; color: modelData.color || desk.pal.accent }
                            Column {
                                Text { width: 300; elide: Text.ElideRight; text: modelData.title; color: modelData.done ? desk.pal.dim : desk.pal.fg; font.strikeout: !!modelData.done; font.family: desk.sans; font.pixelSize: 15; font.weight: Font.Medium }
                                Text { text: modelData.sub || ""; color: desk.pal.dim; font.family: desk.sans; font.pixelSize: 12 }
                            }
                        }
                    }
                }
            }
        }

        // ---- system rings ----
        Glass {
            pal: desk.pal; tint: 0.66; radius: 28; width: 362; height: 392
            Column {
                anchors.fill: parent; anchors.margins: 24; spacing: 16
                Item { width: parent.width; height: 14
                    Text { text: "SYSTEM"; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11; font.letterSpacing: 2.2 }
                    Text { anchors.right: parent.right; text: "❖ H"; color: desk.pal.accent; font.family: desk.mono; font.pixelSize: 11 } }
                Grid {
                    columns: 2; columnSpacing: 10; rowSpacing: 18; anchors.horizontalCenter: parent.horizontalCenter
                    Repeater {
                        model: [["cpu", desk.sys.cpu, "%", desk.pal.accent], ["ram", desk.sys.ram, "%", desk.pal.cyan],
                                ["temp", desk.sys.temp, "°", desk.pal.red], ["disk", desk.sys.disk, "%", desk.pal.blue]]
                        Column {
                            width: 150; spacing: 8
                            Item {
                                width: 104; height: 104; anchors.horizontalCenter: parent.horizontalCenter
                                Canvas {
                                    anchors.fill: parent
                                    property real p: Math.min(1, modelData[1] / 100)
                                    onPChanged: requestPaint()
                                    onPaint: { const c = getContext("2d"); c.reset(); c.lineWidth = 9; c.lineCap = "round"
                                        c.strokeStyle = "rgba(255,255,255,0.07)"; c.beginPath(); c.arc(52, 52, 46, 0, 2 * Math.PI); c.stroke()
                                        c.strokeStyle = modelData[3]; c.beginPath(); c.arc(52, 52, 46, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * p); c.stroke() }
                                }
                                Row { anchors.centerIn: parent
                                    Text { text: Math.round(modelData[1]); color: desk.pal.fg; font.family: desk.serif; font.italic: true; font.pixelSize: 30 }
                                    Text { text: modelData[2]; color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11; anchors.baseline: parent.children[0].baseline } }
                            }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[0].toUpperCase(); color: desk.pal.dim; font.family: desk.mono; font.pixelSize: 11; font.letterSpacing: 2 }
                        }
                    }
                }
            }
        }
    }
}
