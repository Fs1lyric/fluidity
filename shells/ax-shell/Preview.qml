// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick
import "Pal.js" as P

Item {
    anchors.fill: parent
    FakeSys { id: fake; title: ""; user: "adriano"; host: "arch"; now: new Date(2025, 0, 8, 21, 33, 0)
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: i < 3 ? 1 : 0, state: i === 1 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 40; sys: fake }
    DashView { x: (parent.width - 760) / 2; y: 48; width: 760; height: 300; sys: fake }
    Rectangle { x: 480; y: 400; width: 960; height: 480; radius: 14; color: "#0c0201"; border.color: "#552826"
        Text { x: 24; y: 22; color: "#dba4a1"; font.family: P.mono; font.pixelSize: 15; lineHeight: 1.25
               text: "adriano@arch ~ λ fastfetch\n  user    adriano\n  hname   arch\n  distro  Arch Linux\n  kernel  6.12.8-arch1-1\n  shell   fish\n\n" +
                     "from fabric.widgets.box import Box\nclass PowerMenu(Box):\n    def __init__(self, **kwargs):" } }
}
