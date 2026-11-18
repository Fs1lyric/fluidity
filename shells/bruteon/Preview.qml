// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; user: "achlys"; weatherPlace: "Thrissur"; weatherCond: "Clear"; now: new Date(2026, 7, 12, 19, 58, 0) }
    WidgetsView { anchors.fill: parent; sys: fake; shown: new Date(2026, 7, 1); remaining: 23 * 60 + 17 }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 150 * parent.width / 1366; sys: fake; bigMusic: true }
}
