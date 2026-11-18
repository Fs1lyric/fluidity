// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "GeistMono-Regular.ttf" }
    FontLoader { source: "GeistMono-Bold.ttf" }
    FakeSys { id: fake; track: "São Paulo (feat. Anitta)"; artist: "The Weeknd"; battery: 1.0; volume: 0.87; wifiStrength: 0.6
              weatherTemp: "28"; wifiOn: true; btOn: true; now: new Date(2025, 5, 21, 19, 35, 8)
              tags: [1, 2, 3, 4, 5].map(i => ({ id: i, count: i < 3 ? 1 : 0, state: i === 2 ? "focused" : "occupied" })) }
    // his rofi waybar-style picker in the middle
    Rectangle { x: 700; y: 470; width: 560; height: 180; radius: 12; color: "#f2272e33"
                Rectangle { x: 20; y: 20; width: 520; height: 48; radius: 8; color: "#414b50"
                            Text { x: 18; anchors.verticalCenter: parent.verticalCenter; text: "❄   select waybar style . . ."; font.family: "Geist Mono"; font.italic: true; font.pixelSize: 15; color: "#d3c6aa" } }
                Rectangle { x: 20; y: 80; width: 520; height: 38; radius: 8; color: "#4f7c5f"
                            Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: "SLANTED-BUBBLES"; font.family: "Geist Mono"; font.pixelSize: 14; color: "#d3c6aa" } }
                Text { x: 32; y: 138; text: "MINIMAL"; font.family: "Geist Mono"; font.pixelSize: 14; color: "#d3c6aa" } }
    BarView { width: parent.width; height: 44; sys: fake; panelOpen: true }
    PanelView { x: parent.width - implicitWidth - 8; y: 50; width: implicitWidth; height: implicitHeight; sys: fake; brightness: 1.0; showSelection: true }
}
