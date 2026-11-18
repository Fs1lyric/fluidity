// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; ramUsed: 7.56; weatherTemp: "27"; weatherCond: "Partly cloudy"; night: false; cpu: 0.05
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: 1, state: i === 3 ? "focused" : i < 3 || i === 10 ? "occupied" : "empty" })) }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 36; sys: fake }
}
