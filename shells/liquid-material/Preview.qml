// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; artist: "Flo Milli"; track: "Never Lose Me (feat. SZA)"; workspace: 7; wired: true; user: "soup"; host: "cachyos-x8664"
              uptime: "1 day, 8 hours, 20 minutes"; now: new Date(2026, 9, 29, 20, 50, 0) }
    ClockView { x: parent.width * 0.43; y: parent.height * 0.17; width: implicitWidth; height: implicitHeight; now: fake.now }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 34; sys: fake
              levels: Array(28).fill(0).map((_, i) => 0.15 + Math.abs(Math.sin(i * 1.3)) * 0.85) }
    ControlCenterView { anchors { top: parent.top; right: parent.right; topMargin: 38; rightMargin: 6 } width: 248; height: implicitHeight
                        sys: fake; banner: "wall.jpg"; shown: new Date(2026, 9, 1) }
}
