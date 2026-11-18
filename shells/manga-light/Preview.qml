// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
    FakeSys { id: fake; track: "Ingooneh"; artist: "@Archive_Najafi"; appClass: "iTerm2"; battery: 0.86; ssid: "DidebanNET"; playing: false
              position: 14; length: 340; volume: 1.0; now: new Date(2025, 0, 1, 19, 12, 0)
              tags: [1, 2, 3, 4, 5].map(i => ({ id: i, count: 1, state: i === 2 ? "focused" : "occupied" })) }
    // his fastfetch card top-left
    Rectangle { x: 24; y: 60; width: 560; height: 190; radius: 8; color: "#fbf1c7"; border.color: "#3c3836"; border.width: 2
                Text { x: 200; y: 14; font.family: "JetBrains Mono"; font.pixelSize: 15; lineHeight: 1.3; textFormat: Text.RichText; color: "#3c3836"
                       text: "<span style='color:#9d0006'>OS</span> : macOS Sequoia 15.2 arm64<br><span style='color:#9d0006'>Kernel</span> : Darwin 24.2.0<br>" +
                             "<span style='color:#076678'>GPU</span> : Apple M1<br><span style='color:#076678'>CPU</span> : Apple M1<br><span style='color:#b57614'>Uptime</span> : 8 hours, 19 mins<br><span style='color:#8f3f71'>Memory</span> : 4.20 GiB / 8.00 GiB" } }
    BarView { width: parent.width; height: 34; sys: fake }
    ClockView { x: parent.width - implicitWidth - 30; y: 58; width: implicitWidth; height: implicitHeight; now: fake.now }
    CavaView { x: parent.width - implicitWidth - 40; y: parent.height - implicitHeight - 40; width: implicitWidth; height: implicitHeight
               levels: [0.02, 0.02, 0.02, 0.05, 0.05, 0.18, 0.2, 0.2, 0.5, 0.95, 0.15, 0.05, 0.45, 0.15, 0.25, 0.55, 0.22, 0.22, 0.2, 0.2, 0.3, 0.15, 0.1, 0.05] }
    PanelView { x: 24; y: 300; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true }
}
