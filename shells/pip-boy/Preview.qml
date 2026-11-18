// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "ShareTechMono.ttf" }
    FakeSys { id: fake; ssid: "vault-101"; volume: 0.9; battery: 0.75; cpu: 0.08; now: new Date(2025, 8, 24, 2, 29, 0); workspace: 1 }
    TopView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 30; sys: fake }
    BottomView { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 28; sys: fake; tab: "STATS" }
}
