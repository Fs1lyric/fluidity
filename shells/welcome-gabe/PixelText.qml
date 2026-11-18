// Big pixel letters like his `figlet -f 3d | lolcat`: each letter is a 5x7 grid of squares coloured along a
// horizontal rainbow (magenta → violet → blue → cyan → green), with a dotted shadow offset down-right.
import QtQuick

Item {
    id: t
    property string text: "WELCOME"
    property int cell: 14
    property real hueFrom: 0.86        // lolcat start (magenta); wraps through blue to green
    property real hueSpan: 0.55
    readonly property var glyphs: ({
        A: ["01110", "10001", "10001", "11111", "10001", "10001", "10001"], B: ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
        C: ["01111", "10000", "10000", "10000", "10000", "10000", "01111"], D: ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
        E: ["11111", "10000", "10000", "11110", "10000", "10000", "11111"], F: ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
        G: ["01111", "10000", "10000", "10011", "10001", "10001", "01111"], H: ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
        I: ["11111", "00100", "00100", "00100", "00100", "00100", "11111"], J: ["00111", "00001", "00001", "00001", "10001", "10001", "01110"],
        K: ["10001", "10010", "10100", "11000", "10100", "10010", "10001"], L: ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
        M: ["10001", "11011", "10101", "10101", "10001", "10001", "10001"], N: ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
        O: ["01110", "10001", "10001", "10001", "10001", "10001", "01110"], P: ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
        Q: ["01110", "10001", "10001", "10001", "10101", "10010", "01101"], R: ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
        S: ["01111", "10000", "10000", "01110", "00001", "00001", "11110"], T: ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
        U: ["10001", "10001", "10001", "10001", "10001", "10001", "01110"], V: ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
        W: ["10001", "10001", "10001", "10101", "10101", "11011", "10001"], X: ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
        Y: ["10001", "10001", "01010", "00100", "00100", "00100", "00100"], Z: ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
        "-": ["00000", "00000", "00000", "11111", "00000", "00000", "00000"], " ": ["000", "000", "000", "000", "000", "000", "000"] })
    readonly property var chars: text.toUpperCase().split("").map(c => glyphs[c] ? c : " ")
    readonly property int cols: chars.reduce((n, c) => n + glyphs[c][0].length + 1, 0) - 1
    implicitWidth: cols * cell + cell / 2; implicitHeight: 7 * cell + cell / 2

    Repeater {
        model: t.chars.length
        Item {
            id: letter
            required property int index
            readonly property var g: t.glyphs[t.chars[index]]
            readonly property int col0: t.chars.slice(0, index).reduce((n, c) => n + t.glyphs[c][0].length + 1, 0)
            x: col0 * t.cell
            Repeater {
                model: 7 * letter.g[0].length
                Item {
                    required property int index
                    readonly property int r: Math.floor(index / letter.g[0].length)
                    readonly property int c: index % letter.g[0].length
                    readonly property color tint: Qt.hsva((t.hueFrom - t.hueSpan * (letter.col0 + c) / Math.max(1, t.cols) + 1) % 1, 0.85, 1, 1)
                    visible: letter.g[r][c] === "1"
                    x: c * t.cell; y: r * t.cell
                    // the dotted 3d shadow
                    Grid { x: t.cell / 2; y: t.cell / 2; columns: 2; spacing: t.cell / 4
                           Repeater { model: 4; Rectangle { width: t.cell / 4; height: t.cell / 4; color: Qt.darker(parent.parent.tint, 2.4) } } }
                    Rectangle { width: t.cell; height: t.cell; color: parent.tint }
                }
            }
        }
    }
}
