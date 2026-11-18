import QtQuick

// Wi-Fi: the networks around you, strongest first; ↵ joins (a password row opens when it needs one).
// Keys: ↑ ↓ pick, ↵ connect / disconnect, r rescan, w Wi-Fi on/off, f forget.
AppBase {
    id: a
    readonly property var nets: d.nets || []
    function bars(s) { return s >= 75 ? "󰤨" : s >= 50 ? "󰤥" : s >= 25 ? "󰤢" : "󰤟" }
    AppHeader { width: parent.width; pal: a.pal; title: "Wi-Fi"; status: a.d.status || ""; on: !!a.d.on; hint: "w" }
    Text { visible: !a.d.on; x: 24; y: 90; text: "Wi-Fi is off. w turns it on."; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
    Text { visible: a.d.on && !a.nets.length; x: 24; y: 90; text: "Looking for networks…"; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
    AppList {
        x: 12; y: 64; width: parent.width - 24
        pal: a.pal; animate: a.animate; sel: a.sel
        rows: a.nets.slice(0, 7).map(n => ({ icon: a.bars(n.signal), on: n.active, title: n.ssid,
            desc: n.active ? "connected" : n.known ? "saved" : n.secure ? "secured" : "open", meta: (n.secure ? "󰌾 " : "") + n.signal + "%" }))
        onPicked: i => a.picked(i)
    }
    Rectangle { // the password row
        visible: !!a.d.ask
        x: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 18; width: parent.width - 40; height: 48; radius: 18
        color: Qt.rgba(0, 0, 0, 0.35); border.width: 1; border.color: a.alpha(a.pal.accent, 0.5)
        Text { x: 16; anchors.verticalCenter: parent.verticalCenter; text: "󰌾  password for " + (a.d.ask || ""); color: a.pal.dim; font.family: a.sans; font.pixelSize: 13 }
        Text { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "•".repeat((a.d.secret || "").length) + "▏"; color: a.pal.accent; font.family: a.mono; font.pixelSize: 16 }
    }
}
