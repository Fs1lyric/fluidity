// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; ssid: "BELL683"; wifiStrength: 0.64; cpu: 0.14; ram: 0.06; temp: 58; battery: 0.96; volume: 0.4 }
    // his windows: rounding 200, 20 px cyan border, see-through when unfocused
    Rectangle { x: 120; y: 140; width: 1680; height: 800; radius: 200; color: Qt.rgba(1, 1, 1, 0.25); border.color: "#ff10ff"; border.width: 20; opacity: 0.6 }
    Rectangle { x: 360; y: 160; width: 760; height: 480; radius: 200; color: "#1b1d2b"; border.color: "#16ffff"; border.width: 20; opacity: 0.9
        Text { anchors.centerIn: parent; text: "Waiting for network..."; color: "#ffffff"; font.pixelSize: 22 } }
    WaybarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 30; sys: fake }
    AdBox { anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter } width: 1000; height: 50; text: "SUper COol ass computer!!" }
    AdBox { anchors { bottom: parent.bottom; right: parent.right; margins: 20 } width: 200; height: 40 }
    AdBox { x: 60; y: 250; width: 200; height: 90 }
    AdBox { anchors { top: parent.top; right: parent.right; topMargin: 60; rightMargin: 100 } width: 200; height: 60 }
    Text { anchors { bottom: parent.bottom; bottomMargin: 14; horizontalCenter: parent.horizontalCenter }
           text: "\"the only wayland compositor powered by a chicken rat\""; color: Qt.rgba(1, 1, 1, 0.75); font.pixelSize: 13 }
}
