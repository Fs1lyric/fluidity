// eDEX's world view: the land tiles of misc/grid.json as dots on a slowly turning sphere, plus a pin.
import QtQuick
import "Pal.js" as P
import "Data.js" as Dt

Canvas {
    id: g
    property real spin: 0
    property real pinLat: 48.8
    property real pinLon: 2.3
    property bool running: true
    NumberAnimation on spin { from: 0; to: 360; duration: 60000; loops: Animation.Infinite; running: g.running }
    onSpinChanged: requestPaint()
    onPaint: {
        const x = getContext("2d"); x.reset();
        const r = Math.min(width, height) / 2 - 4, cx = width / 2, cy = height / 2, tilt = 0.35;
        const proj = (lat, lon) => {
            const la = lat * Math.PI / 180, lo = (lon + spin) * Math.PI / 180;
            let px = Math.cos(la) * Math.sin(lo), py = Math.sin(la), pz = Math.cos(la) * Math.cos(lo);
            const y2 = py * Math.cos(tilt) - pz * Math.sin(tilt), z2 = py * Math.sin(tilt) + pz * Math.cos(tilt);
            return [cx + px * r, cy - y2 * r, z2];
        };
        const L = Dt.land;
        for (let i = 0; i < L.length; i += 2) {
            const p = proj(L[i], L[i + 1]);
            if (p[2] < 0) continue;
            x.fillStyle = P.a(0.25 + 0.75 * p[2]);
            x.fillRect(p[0], p[1], 1.6, 1.6);
        }
        const q = proj(pinLat, pinLon);
        if (q[2] > 0) {
            x.strokeStyle = P.c; x.lineWidth = 1; x.beginPath(); x.moveTo(q[0], q[1]);
            x.lineTo(q[0] + 18, q[1] - 18); x.stroke();
            x.beginPath(); x.arc(q[0], q[1], 3, 0, 2 * Math.PI); x.fillStyle = P.c; x.fill();
        }
        // the frame corners eDEX draws around the globe
        x.strokeStyle = P.a(0.6); x.lineWidth = 1;
        for (const [ax, ay, dx, dy] of [[4, 4, 1, 1], [width - 4, 4, -1, 1], [4, height - 4, 1, -1], [width - 4, height - 4, -1, -1]]) {
            x.beginPath(); x.moveTo(ax + 10 * dx, ay); x.lineTo(ax, ay); x.lineTo(ax, ay + 10 * dy); x.stroke();
        }
    }
}
