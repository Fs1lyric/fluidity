// A line graph of the last N values (0..1), eDEX style: thin bright line, faint grid.
import QtQuick
import "Pal.js" as P

Canvas {
    id: g
    property var values: []
    property var values2: []
    property bool centered: false   // network traffic: up above, down below the middle line
    onValuesChanged: requestPaint()
    onPaint: {
        const x = getContext("2d"); x.reset();
        x.strokeStyle = P.a(0.15); x.lineWidth = 1;
        for (let i = 1; i < 4; i++) { x.beginPath(); x.moveTo(0, height * i / 4); x.lineTo(width, height * i / 4); x.stroke(); }
        for (let i = 1; i < 6; i++) { x.beginPath(); x.moveTo(width * i / 6, 0); x.lineTo(width * i / 6, height); x.stroke(); }
        const line = (v, sign) => {
            if (!v.length) return;
            x.beginPath(); x.strokeStyle = P.c; x.lineWidth = 1.2;
            for (let i = 0; i < v.length; i++) {
                const px = width * i / Math.max(1, v.length - 1);
                const py = g.centered ? height / 2 - sign * v[i] * height / 2 : height - v[i] * height;
                i ? x.lineTo(px, py) : x.moveTo(px, py);
            }
            x.stroke();
        };
        line(values, 1); line(values2, -1);
    }
}
