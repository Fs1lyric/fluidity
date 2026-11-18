// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "Silkscreen-Bold.ttf" }
    FakeSys { id: fake; hasPlayer: false; volume: 0.42; now: new Date(2023, 4, 4, 17, 34, 0) }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 30; sys: fake }
    ClockView { x: parent.width - implicitWidth - parent.width * 0.04; y: parent.height * 0.08; now: fake.now
                days: [[4, 26, 20, 116], [5, 30, 21, 176], [6, 32, 22, 113], [7, 30, 21, 116], [8, 22, 19, 119]].map(d => ({ day: new Date(2023, 4, d[0]), max: d[1], min: d[2], code: d[3] })) }
    DockView { x: (parent.width - implicitWidth) / 2; y: parent.height - 60 }
}
