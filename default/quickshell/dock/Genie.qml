import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "GenieMath.js" as Geometry

// One frozen frame per minimized window; no background capture while idle.
PanelWindow {
    id: genie
    required property var host
    property var snapshots: ({})
    property var pending: null
    property var frame: null
    property rect windowGeometry
    property rect iconGeometry
    property bool restoring: false
    property bool busy: false
    property bool drawing: false
    property bool armed: false
    property bool frameReady: false
    property real progress: 0

    screen: host.screen
    visible: busy
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: -1
    mask: Region {}
    WlrLayershell.namespace: "qs-dock-genie"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    function prune() {
        const next = {};
        for (const w of host.windows)
            if (snapshots[w.address]) next[w.address] = snapshots[w.address];
        snapshots = next;
    }

    function cancelPreparation() {
        if (!armed) return;
        captureTimeout.stop();
        geometryQuery.running = false;
        delete snapshots[pending.address];
        armed = false;
        busy = false;
        pending = null;
        frame = null;
        shot.captureSource = null;
    }

    function commit() {
        drawing = true;
        host.minimizeNow(pending);
        motion.start();
    }

    function start(w, target, reverse, prepareOnly) {
        if (busy) {
            if (armed && pending.address === w.address && !reverse && !prepareOnly) {
                armed = false;
                iconGeometry = target;
                if (frameReady) commit();
            }
            return;
        }
        const saved = snapshots[w.address];
        if (!w.top.wayland || (reverse && !saved)) {
            if (reverse) host.restoreNow(w); else host.minimizeNow(w);
            return;
        }
        pending = w;
        restoring = reverse;
        armed = !!prepareOnly;
        frameReady = false;
        iconGeometry = target;
        progress = reverse ? 1 : 0;
        drawing = false;
        busy = true;
        if (reverse) {
            windowGeometry = saved.geometry;
            frame = saved.frame;
            drawing = true;
            motion.start();
        } else {
            captureTimeout.restart();
            geometryQuery.running = true;
        }
    }

    Process {
        id: geometryQuery
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector { onStreamFinished: {
            if (!genie.pending || !captureTimeout.running) return;
            try {
                const client = JSON.parse(text).find(c => c.address === genie.host.addr(genie.pending));
                // hyprbars is compositor decoration, outside the client's buffer.
                const r = Geometry.windowRect(client ?? {}, genie.screen, 28);
                if (!r) return;
                genie.windowGeometry = Qt.rect(r.x, r.y, r.width, r.height);
                shot.captureSource = genie.screen;
            } catch (error) { console.warn("Genie geometry:", error); }
        } }
    }

    function finish() {
        captureTimeout.stop();
        if (restoring && pending) {
            host.restoreNow(pending);
            delete snapshots[pending.address];
        }
        // Leave the last full-size frame up until the restored client has been mapped.
        settle.restart();
    }

    Timer { id: settle; interval: 16; onTriggered: {
        genie.busy = false;
        genie.drawing = false;
        genie.pending = null;
        genie.frame = null;
        shot.captureSource = null;
    } }
    Timer { id: captureTimeout; interval: 600; onTriggered: {
        if (genie.armed) { genie.cancelPreparation(); return; }
        if (genie.pending) genie.host.minimizeNow(genie.pending);
        genie.finish();
    } }

    ScreencopyView {
        id: shot
        // Render only into grabToImage, never flash a full-screen capture on the desktop.
        x: -width
        width: genie.width
        height: genie.height
        constraintSize: Qt.size(genie.screen.width, genie.screen.height)
        visible: genie.busy && !genie.drawing && !genie.restoring
        live: false
        paintCursor: false
        onHasContentChanged: {
            if (!hasContent || !genie.pending || genie.restoring) return;
            Qt.callLater(() => grabToImage(result => {
                if (!genie.pending || !captureTimeout.running) return;
                captureTimeout.stop();
                genie.frame = result;
                genie.snapshots[genie.pending.address] = {
                    frame: result, geometry: genie.windowGeometry
                };
                genie.frameReady = true;
                if (!genie.armed) genie.commit();
            }, Qt.size(genie.screen.width, genie.screen.height)));
        }
    }
    Image {
        id: frozen
        source: genie.frame ? genie.frame.url : ""
        visible: false
        cache: false
    }
    ShaderEffect {
        anchors.fill: parent
        visible: genie.drawing
        property variant source: frozen
        property vector4d windowRect: Qt.vector4d(genie.windowGeometry.x, genie.windowGeometry.y,
                                                 genie.windowGeometry.width, genie.windowGeometry.height)
        property vector4d iconRect: Qt.vector4d(genie.iconGeometry.x, genie.iconGeometry.y,
                                               genie.iconGeometry.width, genie.iconGeometry.height)
        property vector4d sourceRect: Qt.vector4d(genie.windowGeometry.x / genie.screen.width,
                                                 genie.windowGeometry.y / genie.screen.height,
                                                 genie.windowGeometry.width / genie.screen.width,
                                                 genie.windowGeometry.height / genie.screen.height)
        property real progress: genie.progress
        mesh: GridMesh { resolution: Qt.size(32, 64) }
        vertexShader: "shaders/genie.vert.qsb"
        fragmentShader: "shaders/genie.frag.qsb"
        blending: true
    }
    NumberAnimation {
        id: motion
        target: genie; property: "progress"
        from: genie.restoring ? 1 : 0
        to: genie.restoring ? 0 : 1
        duration: 180
        easing.type: Easing.Linear
        onFinished: genie.finish()
    }
}
