// A tiny pixel sprite from rows of characters: '.' empty, any other letter looks up `colors`.
import QtQuick

Canvas {
    id: p
    property var rows: []
    property var colors: ({})
    property int scale: 2
    width: (rows[0] ?? "").length * scale; height: rows.length * scale
    onRowsChanged: requestPaint()
    onColorsChanged: requestPaint()
    onPaint: {
        const g = getContext("2d"); g.reset();
        for (let y = 0; y < rows.length; y++)
            for (let x = 0; x < rows[y].length; x++) {
                const c = colors[rows[y][x]];
                if (c) { g.fillStyle = c; g.fillRect(x * scale, y * scale, scale, scale) }
            }
    }
}
