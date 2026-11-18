// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
    FakeSys { id: fake; track: "Chest Pain (I Love)"; artist: "Malice Mizer"; position: 0; length: 208; weatherTemp: "3.8"; weatherCond: "Overcast"
              ssid: "Fibernet-IA"; btConnected: 1; volume: 0.51; battery: 1.0; now: new Date(2026, 2, 30, 23, 39, 59)
              tags: [1, 2, 3, 4, 5, 6, 7, 8].map(i => ({ id: i, count: i < 4 ? 1 : 0, state: i === 3 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    // one terminal in his dark windows
    Rectangle { x: 12; y: 46; width: 1040; height: 1022; radius: 12; color: "#e6111417"
                Text { x: 22; y: 18; color: "#e3e4da"; font.family: "JetBrains Mono"; font.pixelSize: 14; lineHeight: 1.4; textFormat: Text.RichText
                       text: "<span style='color:#d7e59b'>ilya@nixos</span> <span style='color:#878880'>~/nixos-configuration</span><br>❯ nix flake update<br>" +
                             "<span style='color:#878880'>• Updated input 'nixpkgs'</span><br>❯ sudo nixos-rebuild switch --flake .#<br>building the system configuration…" } }
    BarView { width: parent.width; height: 36; sys: fake }
    PanelView { x: parent.width - implicitWidth - 8; y: 42; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true }
}
