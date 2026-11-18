// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "Figtree-Regular.ttf" }
    FontLoader { source: "Figtree-Medium.ttf" }
    FontLoader { source: "Figtree-SemiBold.ttf" }
    FakeSys { id: fake; now: new Date(2025, 11, 26, 15, 9, 0); volume: 0.55
              tags: [1, 2, 3, 4, 5].map(i => ({ id: i, count: 1, state: i === 1 ? "focused" : i < 4 ? "occupied" : "empty" })) }
    // his wezterm windows on the right
    Rectangle { x: 1270; y: 400; width: 520; height: 640; radius: 10; color: "#f2141118"; border.color: "#27222f"
                Text { x: 24; y: 20; font.family: "monospace"; font.pixelSize: 13; lineHeight: 1.45; color: "#a095b2"; textFormat: Text.RichText
                       text: "<span style='color:#9e70d7'>def</span> mount<br>&nbsp;&nbsp;setup<br>&nbsp;&nbsp;emit(:before_mount)<br>&nbsp;&nbsp;@tree = render!<br>&nbsp;&nbsp;@mounted = <span style='color:#d3a0e6'>true</span><br><span style='color:#9e70d7'>end</span>" } }
    Rectangle { x: 1460; y: 40; width: 420; height: 300; radius: 10; color: "#f2141118"; border.color: "#27222f"
                Text { x: 20; y: 16; font.family: "Figtree"; font.pixelSize: 13; lineHeight: 1.5; color: "#a095b2"; textFormat: Text.RichText
                       text: "<span style='color:#b4a0d4'>Artist&nbsp;&nbsp;&nbsp;Title</span><br>Cecily&nbsp;&nbsp;&nbsp;Crush<br><span style='color:#f4f3f6'>Cecily&nbsp;&nbsp;&nbsp;Love is the time of Discord</span><br>Cecily&nbsp;&nbsp;&nbsp;Priestess<br>Cecily&nbsp;&nbsp;&nbsp;Everything to…" } }
    BarView { width: parent.width; height: 30; sys: fake }
    ClockView { x: 96; y: parent.height - implicitHeight - 80; now: fake.now }
    SearchView { x: 24; y: 46; width: implicitWidth; height: implicitHeight; query: "1 + 2 * 3"; answer: "7"
                 results: [{ group: "Commands", title: "Lock", sub: "", glyph: "\u{F033E}" }, { group: "Commands", title: "Power menu", sub: "", glyph: "\u{F0425}" },
                           { group: "Web", title: "Search \"1 + 2 * 3\" on the web", sub: "", glyph: "\u{F059F}" }] }
}
