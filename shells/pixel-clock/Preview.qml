// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
    FakeSys { id: fake; weatherTemp: "16"; volume: 0.40; ram: 0.43; cpu: 0.04; temp: 45; battery: 0.59; ramUsed: 10; ramTotal: 24
              uptime: "10h 22m"; netDown: 0; netUp: 0; now: new Date(2025, 10, 16, 2, 6, 13)
              tags: [1, 2, 3].map(i => ({ id: i, count: 1, state: i === 3 ? "focused" : "occupied" })) }
    // his fastfetch window on the left
    Rectangle { x: 50; y: 60; width: 560; height: 560; color: "#ee090e13"
                Text { x: 40; y: 40; font.family: "JetBrains Mono"; font.bold: true; font.pixelSize: 18; lineHeight: 1.35; textFormat: Text.RichText; color: "#c5c9c7"
                       text: "<span style='color:#e46876'>&nbsp;&nbsp;___&nbsp;&nbsp;&nbsp;__&nbsp;&nbsp;&nbsp;_<br>&nbsp;/ _ \\___/ /&nbsp;(_)__ ____<br>/_____/\\__/_.__/_/\\_,_/_//_/</span><br><br>" +
                             "user&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#e46876'>bahaa</span><br>hname&nbsp;&nbsp;&nbsp;<span style='color:#dca561'>debian</span><br>distro&nbsp;&nbsp;<span style='color:#98bb6c'>Debian GNU/Linux 13</span><br>kernel&nbsp;&nbsp;<span style='color:#7aa89f'>6.12.48+deb13</span><br>memory&nbsp;&nbsp;<span style='color:#dca561'>8647 | 23733 MiB</span>" } }
    BarView { width: parent.width; height: 28; sys: fake; brightness: 0.4 }
    ClockView { x: parent.width - implicitWidth - 50; y: 70; width: implicitWidth; height: implicitHeight; now: fake.now }
    PanelView { x: (parent.width - implicitWidth) / 2 + 160; y: 360; width: implicitWidth; height: implicitHeight; sys: fake; brightness: 0.4; showSelection: true }
}
