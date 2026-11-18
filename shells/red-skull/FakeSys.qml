// Fixed stand-in for Sys.qml in the off-screen previews (render/render.py). Pure QtQuick, same properties.
import QtQuick

QtObject {
    property date now: new Date(2026, 7, 12, 19, 58, 36)
    property var tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: i < 4 ? 2 : 0,
                       state: i === 1 ? "focused" : i < 4 ? "occupied" : "empty" }))
    property int workspace: 1
    property string title: "Hartshorne - 1977 - Algebraic Geometry.pdf"
    property string appClass: "org.pwmt.zathura"
    property bool hasPlayer: true
    property string track: "Una Velita"
    property string artist: "Bad Bunny"
    property string art: ""
    property bool playing: true
    property real length: 240
    property real position: 141
    property real volume: 0.62
    property bool muted: false
    property bool micMuted: false
    property bool hasBattery: true
    property real battery: 0.74
    property bool charging: false
    property bool wired: false
    property bool wifiOn: true
    property string ssid: "home"
    property real wifiStrength: 0.8
    property bool online: true
    property bool btOn: true
    property int btConnected: 0
    property real cpu: 0.12
    property real ram: 0.41
    property real ramUsed: 12.7
    property real ramTotal: 31.2
    property real temp: 46
    property real diskUsed: 0.62
    property string diskFree: "251G"
    property string uptime: "2 hours, 15 minutes"
    property real netDown: 377
    property real netUp: 204
    property string user: "lyric"
    property string host: "archy"
    property string kernel: "7.2.14-arch1-1"
    property int packages: 1342
    property string weatherCond: "Clear"
    property string weatherTemp: "25"
    property string weatherPlace: "Dhaka"
    property string weatherHumidity: "88%"
    property string weatherWind: "4 km/h"
    property bool night: true
    property string sunrise: "05:24:00"
    property string sunset: "17:18:00"
    property bool caffeine: true
    property var todos: [{ text: "Gotta do some more stuffffff", done: false }, { text: "Get the dots outttttt", done: false }]
    function act(what, arg) {}
}
