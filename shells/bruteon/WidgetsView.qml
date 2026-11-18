// Bruteon's desktop widgets (preview 1 / 3): Tasks and Pomodoro on the left; clock with greeting, calendar
// and weather on the right. Laid out on a 1366 x 768 design and scaled to the screen.
import QtQuick
import "Pal.js" as P

Item {
    id: w
    property var sys
    property date shown: new Date()
    property string mode: "pomodoro"       // pomodoro | stopwatch
    property string phase: "focus"         // focus | break | long
    property int remaining: 25 * 60
    property int watch: 0
    property bool running: false
    signal act(string what, var arg)
    readonly property real s: width / 1366
    readonly property var lengths: ({ focus: 25 * 60, break: 5 * 60, long: 15 * 60 })
    readonly property var cards: [tasks, pomo, clock, cal, weather]
    function mono(px, bold) { return { family: P.mono, pixelSize: px, bold: !!bold } }
    function hello() { const h = (w.sys?.now ?? new Date()).getHours(); return h < 5 ? "Good night" : h < 12 ? "Good morning" : h < 17 ? "Good afternoon" : "Good evening" }

    Item {
        width: 1366; height: 768; scale: w.s; transformOrigin: Item.TopLeft

        Card { id: tasks; x: 12; y: 136; width: 304; height: 220
            Text { x: 14; y: 16; text: P.g(0xf03eb) + "  Tasks"; color: P.ink; font.family: P.mono; font.pixelSize: 14; font.bold: true }
            Text { anchors { right: parent.right; rightMargin: 16 } y: 19; text: (w.sys?.todos ?? []).filter(t => !t.done).length + " active"; color: P.dim; font.family: P.mono; font.pixelSize: 10 }
            Card { x: 12; y: 42; width: 278; height: 34; r: 8; line: 2; drop: 3; fill: P.paper2
                TextInput { id: inp; x: 10; width: 200; anchors.verticalCenter: parent.verticalCenter; color: P.ink; font.family: P.mono; font.pixelSize: 11; clip: true
                            onAccepted: { w.act("todoAdd", text); text = "" }
                    Text { text: "What needs to be done?"; color: P.dim; font: parent.font; visible: !parent.text && !parent.activeFocus } }
                Chip { x: 216; anchors.verticalCenter: parent.verticalCenter; size: 20; glyph: P.g(0xf0765); onClicked: inp.forceActiveFocus() }
                Chip { x: 242; anchors.verticalCenter: parent.verticalCenter; size: 20; fill: P.pink; glyph: "+"; onClicked: { w.act("todoAdd", inp.text); inp.text = "" } } }
            Column { x: 14; y: 92; spacing: 14; width: 276
                Repeater { model: (w.sys?.todos ?? []).slice(0, 4)
                    Row { required property var modelData; required property int index; spacing: 10
                        Rectangle { width: 16; height: 16; radius: 3; color: modelData.done ? P.green : P.paper2; border.color: P.ink; border.width: 2
                            Text { anchors.centerIn: parent; visible: parent.parent.modelData.done; text: "✓"; font.pixelSize: 11; color: P.ink }
                            MouseArea { anchors.fill: parent; onClicked: w.act("todoToggle", parent.parent.index) } }
                        Text { text: modelData.text; color: P.ink; font.family: P.mono; font.pixelSize: 11; font.bold: true; width: 220; elide: Text.ElideRight
                               font.strikeout: modelData.done; opacity: modelData.done ? 0.5 : 1
                               MouseArea { anchors.fill: parent; acceptedButtons: Qt.RightButton; onClicked: w.act("todoRemove", parent.parent.index) } } } } }
        }

        Card { id: pomo; x: 12; y: 372; width: 304; height: 176
            Row { anchors.horizontalCenter: parent.horizontalCenter; y: 12; spacing: 10
                Chip { label: "Pomodoro"; size: 20; fill: w.mode === "pomodoro" ? P.green : P.paper2; round: true; onClicked: { w.mode = "pomodoro"; w.running = false } }
                Chip { label: "Stopwatch"; size: 20; fill: w.mode === "stopwatch" ? P.green : P.paper2; round: true; onClicked: { w.mode = "stopwatch"; w.running = false } } }
            Column { x: 10; y: 72; spacing: 6
                Repeater { model: [["Focus", "focus"], ["Break", "break"], ["Long", "long"]]
                    Chip { required property var modelData; label: modelData[0]; size: 18; round: true; fill: w.phase === modelData[1] ? P.pink : P.paper2
                           onClicked: { w.phase = modelData[1]; w.remaining = w.lengths[w.phase]; w.running = false } } } }
            Rectangle { x: 64; y: 46; width: 176; height: 92; radius: 18; color: P.pink; border.color: P.ink; border.width: 2
                Rectangle { anchors.fill: parent; anchors.margins: 8; radius: 12; color: P.paper2; border.color: P.ink; border.width: 2
                    Text { anchors.centerIn: parent; anchors.verticalCenterOffset: -6; text: P.mmss(w.mode === "pomodoro" ? w.remaining : w.watch); color: P.ink; font.family: P.mono; font.pixelSize: 28; font.bold: true }
                    Text { anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 6 } font.letterSpacing: 2
                           text: "• " + (w.mode === "stopwatch" ? "STOPWATCH" : w.phase.toUpperCase() + " SESSION") + " •"; color: "#c0566e"; font.family: P.mono; font.pixelSize: 8 } } }
            Column { x: 262; y: 54; spacing: 8
                Chip { size: 22; round: true; fill: P.lav; glyph: P.g(0xf0450); onClicked: { w.running = false; w.remaining = w.lengths[w.phase]; w.watch = 0 } }
                Chip { size: 22; round: true; fill: P.orange; glyph: P.g(w.running ? 0xf03e4 : 0xf040a); onClicked: w.running = !w.running }
                Chip { size: 22; round: true; glyph: P.g(0xf0493); onClicked: w.act("settings", null) } }
        }

        Card { id: clock; x: 1366 - 290; y: 72; width: 276; height: 106
            Item { x: 16; y: 8; width: 90; height: 90
                Rectangle { anchors.fill: parent; radius: 45; color: P.paper2; border.color: P.ink; border.width: 3 }
                Repeater { model: 12; Rectangle { required property int index; x: 45 - 1.5; y: 6; width: 3; height: index % 3 === 0 ? 8 : 5; color: P.ink
                                                   transform: Rotation { origin.x: 1.5; origin.y: 39; angle: index * 30 } } }
                Rectangle { x: 45 - 2; y: 22; width: 4; height: 24; radius: 2; color: P.ink; antialiasing: true
                            transform: Rotation { origin.x: 2; origin.y: 23; angle: ((w.sys?.now ?? new Date()).getHours() % 12 + (w.sys?.now ?? new Date()).getMinutes() / 60) * 30 } }
                Rectangle { x: 45 - 1.5; y: 12; width: 3; height: 34; radius: 1.5; color: P.ink; antialiasing: true
                            transform: Rotation { origin.x: 1.5; origin.y: 33; angle: (w.sys?.now ?? new Date()).getMinutes() * 6 } } }
            Rectangle { x: 120; y: 14; width: 2; height: 78; color: "#c9bdb3" }
            Column { x: 134; y: 12; spacing: 2
                Text { text: P.g(0xf0594) + " " + w.hello() + ", " + (w.sys?.user ?? ""); color: P.ink; font.family: P.mono; font.pixelSize: 9; font.bold: true }
                Row { spacing: 6
                    Text { text: Qt.formatDateTime(w.sys?.now ?? new Date(), "h:mm AP").split(" ")[0]; color: P.ink; font.family: P.mono; font.pixelSize: 30; font.bold: true }
                    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 22; height: 14; radius: 3; color: P.lav; border.color: P.ink; border.width: 1.5
                        Text { anchors.centerIn: parent; text: Qt.formatDateTime(w.sys?.now ?? new Date(), "AP"); font.family: P.mono; font.pixelSize: 8; color: P.ink } } }
                Text { text: Qt.formatDateTime(w.sys?.now ?? new Date(), "dddd, MMMM d"); color: P.ink; font.family: P.mono; font.pixelSize: 9; font.bold: true } }
        }

        Card { id: cal; x: 1366 - 290; y: 192; width: 276; height: 280
            Text { x: 14; y: 16; text: Qt.formatDate(w.shown, "MMMM yyyy"); color: P.ink; font.family: P.mono; font.pixelSize: 15; font.bold: true }
            Row { anchors { right: parent.right; rightMargin: 14 } y: 12; spacing: 8
                Chip { size: 22; round: true; fill: P.pink; glyph: "←"; onClicked: w.shown = new Date(w.shown.getFullYear(), w.shown.getMonth() - 1, 1) }
                Chip { size: 22; round: true; fill: P.green; glyph: "→"; onClicked: w.shown = new Date(w.shown.getFullYear(), w.shown.getMonth() + 1, 1) } }
            Grid { x: 12; y: 48; columns: 7; columnSpacing: 0; rowSpacing: 0
                Repeater { model: ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
                    Text { required property string modelData; width: 36; height: 22; horizontalAlignment: Text.AlignHCenter; text: modelData; color: P.dim; font.family: P.mono; font.pixelSize: 8 } }
                Repeater { model: 42
                    Item { required property int index; width: 36; height: 34
                        readonly property date first: new Date(w.shown.getFullYear(), w.shown.getMonth(), 1)
                        readonly property date day: new Date(first.getFullYear(), first.getMonth(), 1 - first.getDay() + index)
                        readonly property bool today: day.toDateString() === (w.sys?.now ?? new Date()).toDateString()
                        Rectangle { anchors.centerIn: parent; width: 28; height: 28; radius: 14; visible: parent.today; color: P.green; border.color: P.ink; border.width: 2 }
                        Text { anchors.centerIn: parent; text: parent.day.getDate(); font.family: P.mono; font.pixelSize: 11; font.bold: parent.day.getMonth() === w.shown.getMonth()
                               color: parent.day.getMonth() !== w.shown.getMonth() ? "#c9bdb3" : parent.day.getDay() % 6 === 0 ? P.dim : P.ink } } } }
        }

        Card { id: weather; x: 1366 - 290; y: 484; width: 276; height: 94
            Text { x: 16; anchors.verticalCenter: parent.verticalCenter; text: P.g(w.sys?.night ? 0xf0594 : 0xf0599); color: P.ink; font.family: P.mono; font.pixelSize: 26 }
            Text { x: 54; anchors.verticalCenter: parent.verticalCenter; text: (w.sys?.weatherTemp || "--") + "°"; color: P.ink; font.family: P.mono; font.pixelSize: 26; font.bold: true }
            Rectangle { x: 124; y: 14; width: 2; height: 66; color: "#c9bdb3" }
            Column { x: 138; y: 14; spacing: 4
                Text { text: P.g(0xf034e) + " " + (w.sys?.weatherPlace || "—"); color: P.ink; font.family: P.mono; font.pixelSize: 11; font.bold: true }
                Text { text: w.sys?.weatherCond || ""; color: P.ink; font.family: P.mono; font.pixelSize: 9 }
                Row { spacing: 4
                    Rectangle { width: hu.implicitWidth + 10; height: 14; radius: 7; color: P.lav; border.color: P.ink; border.width: 1.5
                        Text { id: hu; anchors.centerIn: parent; text: P.g(0xf058e) + " " + (w.sys?.weatherHumidity ?? ""); font.family: P.mono; font.pixelSize: 7; color: P.ink } }
                    Rectangle { width: wi.implicitWidth + 10; height: 14; radius: 7; color: P.green; border.color: P.ink; border.width: 1.5
                        Text { id: wi; anchors.centerIn: parent; text: P.g(0xf059d) + " " + (w.sys?.weatherWind ?? ""); font.family: P.mono; font.pixelSize: 7; color: P.ink } } } }
        }
    }
    Timer { interval: 1000; repeat: true; running: w.running
            onTriggered: { if (w.mode === "stopwatch") { w.watch++; return }
                           w.remaining--; if (w.remaining <= 0) { w.running = false; w.act("exec", ["notify-send", "Pomodoro", w.phase + " session done"]); w.remaining = w.lengths[w.phase] } } }
}
