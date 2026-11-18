// tty-clock's block digits: each glyph is a 3x5 grid of solid squares (the post's big "02:06: 13").
import QtQuick

Row {
    id: b
    property string text: "00:00"
    property int cell: 14
    property color color: "#8ea4a2"
    spacing: cell
    readonly property var font: ({
        "0": ["###", "#.#", "#.#", "#.#", "###"], "1": ["..#", "..#", "..#", "..#", "..#"],
        "2": ["###", "..#", "###", "#..", "###"], "3": ["###", "..#", "###", "..#", "###"],
        "4": ["#.#", "#.#", "###", "..#", "..#"], "5": ["###", "#..", "###", "..#", "###"],
        "6": ["###", "#..", "###", "#.#", "###"], "7": ["###", "..#", "..#", "..#", "..#"],
        "8": ["###", "#.#", "###", "#.#", "###"], "9": ["###", "#.#", "###", "..#", "###"],
        ":": [".", "#", ".", "#", "."], " ": ["."] })
    Repeater {
        model: b.text.split("")
        Grid {
            required property string modelData
            readonly property var rows: b.font[modelData] ?? b.font[" "]
            columns: rows[0].length
            Repeater { model: rows.join("").split("")
                       Rectangle { required property string modelData; width: b.cell; height: b.cell; color: modelData === "#" ? b.color : "transparent" } }
        }
    }
}
