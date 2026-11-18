// The wallpaper, drawn by the shell so it can change the way the post does:
//   character: a thin line draws the new picture's outline over the old one (spreading from the subject),
//              then the new world grows out of those lines until it fills the screen
//   colonies:  no subject, so the new picture spreads in as pixel colonies eating the old one
// progress runs 0..2 (character: 0..1 outline, 1..2 growth) or 0..1 (colonies).
import QtQuick
import QtQuick.Effects

Item {
    id: v
    property url current: ""          // the picture on screen when idle
    property url incoming: ""
    property url edges: ""
    property string mode: "character"
    property real cx: width / 2
    property real cy: height / 2
    property color line: "#ffffff"
    property real progress: 0
    property bool running: false
    readonly property real reach: Math.hypot(Math.max(cx, width - cx), Math.max(cy, height - cy)) * 1.05
    signal outlineDone()
    signal finished()

    function go(next, edgeUrl, info) {
        colonies.reset();
        v.incoming = next; v.edges = edgeUrl; v.grow = String(edgeUrl).replace("edges.png", "grow.png");
        v.mode = info.mode; v.cx = info.cx * v.width / 1920; v.cy = info.cy * v.height / 1080;
        v.progress = 0; v.running = true;
        anim.to = v.mode === "character" ? 2 : 1;
        anim.duration = v.mode === "character" ? 2600 : 1800;
        anim.restart();
        if (v.mode === "colonies") colonies.start();
    }
    NumberAnimation { id: anim; target: v; property: "progress"; from: 0; easing.type: Easing.InOutSine
        onFinished: { v.current = v.incoming; v.running = false; v.finished() } }
    onProgressChanged: if (mode === "character" && progress >= 1 && running && !_told) { _told = true; outlineDone() }
    property bool _told: false
    onRunningChanged: if (running) _told = false

    Rectangle { anchors.fill: parent; color: "#000000" }
    Image { id: base; anchors.fill: parent; source: v.current; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: false }

    // ---- character: the outline drawing itself, revealed outward from the subject
    Item {
        id: lineMask; anchors.fill: parent; visible: false; layer.enabled: true
        Rectangle { x: v.cx - width / 2; y: v.cy - height / 2; width: v.reach * 2 * Math.min(1, v.progress * 1.1); height: width; radius: width / 2 }
    }
    Image { id: lines; anchors.fill: parent; source: v.edges; visible: false; fillMode: Image.Stretch; asynchronous: true }
    MultiEffect {
        anchors.fill: parent; source: lines
        visible: v.running && v.mode === "character"
        colorization: 1; colorizationColor: v.line
        maskEnabled: true; maskSource: lineMask
        opacity: v.progress < 1.6 ? 1 : Math.max(0, (2 - v.progress) / 0.4)
    }

    // ---- character: the world grows out of the lines: grow.png is opaque on the outline and fades with distance
    // from it, so raising the threshold reveals the new picture outward from its own outline
    property url grow: ""
    Image { id: growMap; anchors.fill: parent; source: v.grow; visible: false; asynchronous: true; smooth: true }
    Image { id: next; anchors.fill: parent; source: v.incoming; visible: false; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: false }
    MultiEffect {
        anchors.fill: parent; source: next
        visible: v.running && v.mode === "character" && v.progress > 1
        maskEnabled: true; maskSource: growMap; maskThresholdMin: Math.max(0, 1 - Math.pow(Math.max(0, v.progress - 1), 1.8)); maskSpreadAtMin: 0.08
    }

    // ---- colonies: cells spread from a few seeds and eat the old picture
    Canvas {
        id: colonies
        anchors.fill: parent; visible: false; layer.enabled: true
        readonly property int cols: 96
        readonly property int rows: 54
        property var cells: []
        property var front: []
        function reset() { cells = new Array(cols * rows).fill(false); front = []; requestPaint() }
        function start() {
            for (let i = 0; i < 7; i++) { const k = Math.floor(Math.random() * cols * rows); cells[k] = true; front.push(k) }
            tick.start();
        }
        Timer {
            id: tick; interval: 33; repeat: true
            onTriggered: {
                const c = colonies, nf = [];
                for (const k of c.front) {
                    const x = k % c.cols, y = Math.floor(k / c.cols);
                    for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
                        const nx = x + dx, ny = y + dy, n = ny * c.cols + nx;
                        if (nx < 0 || ny < 0 || nx >= c.cols || ny >= c.rows || c.cells[n]) continue;
                        if (Math.random() < 0.42) { c.cells[n] = true; nf.push(n) } else nf.push(k);
                    }
                }
                c.front = [...new Set(nf)];
                c.requestPaint();
                if (!v.running) stop();
            }
        }
        onPaint: {
            const g = getContext("2d"), w = width / cols, h = height / rows;
            g.reset(); g.fillStyle = "#ffffff";
            for (let k = 0; k < cells.length; k++) if (cells[k]) g.fillRect((k % cols) * w, Math.floor(k / cols) * h, w + 0.5, h + 0.5);
        }
    }
    MultiEffect {
        anchors.fill: parent; source: next
        visible: v.running && v.mode === "colonies"
        maskEnabled: true; maskSource: colonies
    }
}
