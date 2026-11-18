// A hairline sparkline (Canvas), newest value on the right.
import QtQuick
import "Pal.js" as P

Canvas {
    id: c
    property var values: []
    property color stroke: P.blue
    onValuesChanged: requestPaint()
    onPaint: {
        const g = getContext("2d"); g.reset();
        if (values.length < 2) return;
        g.strokeStyle = stroke; g.lineWidth = 1.2; g.beginPath();
        for (let i = 0; i < values.length; i++) {
            const x = i / (values.length - 1) * width, y = height - 1 - Math.max(0, Math.min(1, values[i])) * (height - 2);
            i ? g.lineTo(x, y) : g.moveTo(x, y);
        }
        g.stroke();
    }
}
