// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; ramUsed: 13.3; ramTotal: 15.6; diskFree: "77G"; netDown: 0; netUp: 0; ssid: "10.100.102.22"; now: new Date(2019, 5, 14, 15, 48, 0)
              tags: [1, 2, 3].map(i => ({ id: i, count: 1, state: i === 1 ? "focused" : "occupied" })) }
    DeskView { x: 60; y: 60; width: 640; sys: fake; hist: Array(60).fill(0).map((_, i) => [0, 0, 0.1, 0.4, 0.05, 0.2][i % 6] * (i > 30 ? 1 : 0.3))
               levels: [0.3, 0.35, 0.3, 0.32, 0.45, 0.8, 0.75, 0.55, 0.3, 0.2, 0.15, 0.2, 0.25, 0.35, 0.3, 0.25, 0.35, 0.3, 0.2, 0.3, 0.25, 0.2, 0.3, 0.25,
                        0.3, 0.2, 0.35, 0.3, 0.55, 0.85, 0.75, 0.4, 0.3, 0.3, 0.32, 0.35] }
    Rectangle { x: 740; y: 60; width: 1120; height: 960; color: "#e6141830"; border.color: "#2d496f"
        Text { x: 30; y: 24; color: "#e6e6f0"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; lineHeight: 1.35; textFormat: Text.RichText
               text: "<span style='color:#46bdff'>const</span> {app, BrowserWindow} = <span style='color:#ff16b0'>require</span>(<span style='color:#b6f23a'>'electron'</span>)<br>" +
                     "<span style='color:#46bdff'>const</span> os = <span style='color:#ff16b0'>require</span>(<span style='color:#b6f23a'>'os'</span>);<br><br>" +
                     "<span style='color:#46bdff'>if</span> (os.platform() == <span style='color:#b6f23a'>'linux'</span>) {<br>&nbsp;&nbsp;app.disableHardwareAcceleration()<br>}<br><br>" +
                     "<span style='color:#6b6f9a'><i>// Keep a global reference of the window object</i></span><br><span style='color:#46bdff'>let</span> mainWindow" } }
    BarView { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 22; sys: fake }
}
