import QtQuick
import Qt5Compat.GraphicalEffects

// Golden Gate's Liquid Glass (macOS 27): a tint over Hyprland's blur (the layer rule
// `qs-lyric-.*` blurs whatever this draws), a 1 px specular rim, light caught along the bottom
// edge, and a soft drop shadow. The dark tint was measured off Apple's screenshots (refs/):
// near-opaque black at the top (0.95), 0.80 through the middle, 0.52 at the bottom edge, so
// the backdrop glows through the lower half. Taller shapes (the results card) keep the bottom
// darker so rows stay readable.
// Plain QtQuick so the Spotlight and Ask views render offscreen.
Item {
    id: glass

    property real radius: height / 2
    property bool dark: true
    property bool shadow: true
    property real strength: 1          // scales the dark tint; the Show Results pill is lighter glass
    // 0 for a capsule, rising to 1 as the shape grows into a tall card.
    readonly property real tall: Math.max(0, Math.min(1, (height - 90) / 160))

    RectangularGlow {
        visible: glass.shadow
        anchors { fill: parent; topMargin: 10; leftMargin: 6; rightMargin: 6 }
        glowRadius: 22
        spread: 0
        cornerRadius: Math.min(glass.radius, height / 2) + glowRadius
        color: Qt.rgba(0, 0, 0, glass.dark ? 0.28 : 0.12)
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.min(glass.radius, height / 2)
        gradient: Gradient {
            GradientStop { position: 0; color: glass.dark ? Qt.rgba(0, 0, 0, 0.95 * glass.strength) : Qt.rgba(1, 1, 1, 0.55) }
            GradientStop { position: 0.45; color: glass.dark ? Qt.rgba(0, 0, 0, (0.80 + 0.04 * glass.tall) * glass.strength) : Qt.rgba(1, 1, 1, 0.46) }
            GradientStop { position: 1; color: glass.dark ? Qt.rgba(0, 0, 0, (0.52 + 0.22 * glass.tall) * glass.strength) : Qt.rgba(1, 1, 1, 0.38) }
        }
    }

    Canvas {
        id: rim
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: glass
            function onRadiusChanged() { rim.requestPaint() }
            function onDarkChanged() { rim.requestPaint() }
        }
        onPaint: {
            const c = getContext("2d");
            c.reset();
            if (width < 2 || height < 2) return;
            const g = c.createLinearGradient(0, 0, 0, height);
            const a = glass.dark ? [0.24, 0.06, 0.30] : [0.85, 0.35, 0.60];
            g.addColorStop(0, `rgba(255,255,255,${a[0]})`);
            g.addColorStop(0.5, `rgba(255,255,255,${a[1]})`);
            g.addColorStop(1, `rgba(255,255,255,${a[2]})`);
            c.strokeStyle = g;
            c.lineWidth = 1;
            const r = Math.max(0, Math.min(glass.radius, height / 2, width / 2) - 0.5);
            // Light caught inside the bottom edge, clipped to the shape.
            const band = Math.min(height / 2, 18);
            const b = c.createLinearGradient(0, height - band, 0, height);
            b.addColorStop(0, "rgba(255,255,255,0)");
            b.addColorStop(1, `rgba(255,255,255,${glass.dark ? 0.07 : 0.18})`);
            c.save();
            c.beginPath();
            c.roundedRect(0, 0, width, height, r + 0.5, r + 0.5);
            c.clip();
            c.fillStyle = b;
            c.fillRect(0, height - band, width, band);
            c.restore();
            c.beginPath();
            c.roundedRect(0.5, 0.5, width - 1, height - 1, r, r);
            c.stroke();
        }
    }
}
