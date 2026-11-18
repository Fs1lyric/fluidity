// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "FiraCode-Regular.ttf" }
    FontLoader { source: "FiraCode-Bold.ttf" }
    FakeSys { id: fake; track: "IV. Sweatpants"; artist: "Childish Gambino"; position: 32; length: 181; ssid: "Gabe"; netUp: 5120; netDown: 6144
              diskFree: "117 GB"; cpu: 0.17; ram: 0.5; temp: 60; battery: 1.0; charging: true; volume: 0.58; packages: 1101; appClass: "w_popup"
              now: new Date(2022, 1, 1, 15, 54, 0)
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: 1, state: i === 10 ? "focused" : "occupied" })) }
    // his fastfetch and weather kitties behind the splash
    Rectangle { x: 34; y: 214; width: 750; height: 450; color: "#cc262338"
                Text { x: 356; y: 36; font.family: "Fira Code"; font.pixelSize: 13; lineHeight: 1.3; color: "#6c6c8c"; textFormat: Text.RichText
                       text: "<b>gabe@redbook</b><br>------------<br>OS: Arch Linux x86_64<br>Kernel: 5.16.5-arch1-1<br>Uptime: 1 day, 6 hours<br>Packages: 1101 (pacman)<br>WM: bspwm<br>Terminal: kitty" } }
    Rectangle { x: 1234; y: 214; width: 450; height: 250; color: "#cc262338"
                Text { x: 30; y: 36; font.family: "Fira Code"; font.pixelSize: 13; lineHeight: 1.3; color: "#6c6c8c"; text: "Weather report: Honolulu\n\n        Partly cloudy\n        +27(28) °C\n        ← 20 km/h" } }
    TopBar { width: parent.width; height: 22; sys: fake }
    BottomBar { width: parent.width; height: 22; y: parent.height - 22; sys: fake; brightness: 1.0 }
    Splash { x: 120; y: 120; grow: 1; name: "LYRIC"; scale: 0.72; transformOrigin: Item.TopLeft }
    PanelView { x: parent.width - implicitWidth - 40; y: 470; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true; scale: 0.9; transformOrigin: Item.TopLeft
                levels: Array(48).fill(0).map((_, i) => 0.25 + 0.2 * Math.sin(i / 3) + 0.15 * Math.cos(i / 1.7)) }
}
