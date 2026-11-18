// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; hasPlayer: false; playing: false; muted: true; battery: 1; host: "victus"; weatherTemp: "23"; weatherCond: "Overcast"; weatherPlace: "Carthage"
              weatherHumidity: "64%"; weatherWind: "14 km/h"; night: false; now: new Date(2026, 9, 17, 12, 13, 59); workspace: 1; cpu: 0.06; ram: 0.16; diskUsed: 0.16 }
    DeskView { anchors.fill: parent; sys: fake }
    TopView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 40; sys: fake }
    TelemetryView { x: parent.width - 250; y: 40; width: 240; height: parent.height - 50; sys: fake
                    cpuHist: Array(40).fill(0).map((_, i) => i === 34 ? 0.5 : 0.05 + (i % 7) * 0.01); netHist: Array(40).fill(0).map((_, i) => i === 12 || i === 30 ? 0.4 : 0.02) }
}
