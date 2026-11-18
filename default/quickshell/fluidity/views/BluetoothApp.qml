import QtQuick

// Bluetooth: paired devices first, then what a scan finds. Keys: ↑ ↓ pick, ↵ connect / disconnect (pairs
// a new one), s scan, b power, x forget.
AppBase {
    id: a
    readonly property var devs: d.devs || []
    AppHeader { width: parent.width; pal: a.pal; title: "Bluetooth"; status: a.d.on ? (a.d.scanning ? "scanning…" : devs.filter(x => x.connected).length + " connected") : "off"; on: !!a.d.on; hint: "b" }
    Text { visible: !a.d.on; x: 24; y: 90; text: "Bluetooth is off. b turns it on."; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
    Text { visible: a.d.on && !a.devs.length; x: 24; y: 90; text: "No devices yet. s scans."; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
    AppList {
        x: 12; y: 64; width: parent.width - 24
        pal: a.pal; animate: a.animate; sel: a.sel
        rows: a.devs.slice(0, 7).map(x => ({ icon: x.icon || "󰂯", on: x.connected, title: x.name,
            desc: x.connected ? "connected" : x.paired ? "paired" : "new · ↵ pairs", meta: x.battery >= 0 && x.battery !== undefined ? "󰥉 " + x.battery + "%" : "" }))
        onPicked: i => a.picked(i)
    }
}
