// quandangv's yuzubar along the bottom: teal, Montserrat Light, salmon underlines.
//   left: X (close window), Hibernate, Suspend, Change Theme. middle: a salmon block of tool icons
//   (draw, link, record, screenshot, region, night light, settings | volume + / colour pick / volume -).
//   right: wifi, vol as a row of dots, and the battery in its own salmon block.
import QtQuick

Rectangle {
    id: b
    property var sys
    signal act(string what, var arg)
    implicitHeight: 30
    gradient: Gradient { orientation: Gradient.Horizontal
        GradientStop { position: 0; color: "#e6005d6a" } GradientStop { position: 1; color: "#e60f6860" } }
    readonly property string icon: "JetBrainsMono Nerd Font"
    Row {
        x: 10; height: parent.height; spacing: 20
        Item_ { text: "X"; onClicked: b.act("close", null) }
        Item_ { text: "Hibernate"; onClicked: b.act("exec", ["systemctl", "hibernate"]) }
        Item_ { text: "Suspend"; onClicked: b.act("exec", ["systemctl", "suspend"]) }
        Item_ { text: "Change Theme"; onClicked: b.act("exec", ["qs", "-c", "fluidity", "ipc", "call", "themepicker", "toggle"]) }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter; height: parent.height; width: tools.implicitWidth + 16; color: "#c06a52"
        Row {
            id: tools; anchors.centerIn: parent; spacing: 4
            Repeater {
                model: [["󰏬", ["bash", "-c", "pkill -x hyprpicker; hyprpicker -a"]], ["󰌹", ["bash", "-c", "wl-paste | xargs -r xdg-open"]],
                        ["󰕧", ["bash", "-c", "pkill -INT wf-recorder || wf-recorder -f ~/Videos/rec-$(date +%s).mp4"]], ["󰄀", "shot"],
                        ["󰩬", ["bash", "-c", "grim -g \"$(slurp)\" ~/Pictures/$(date +%s).png"]], ["󰖔", "night"], ["󰒓", "settings"],
                        ["|", null], ["+", 0.05], ["󰈊", ["bash", "-c", "hyprpicker -a"]], ["−", -0.05]]
                Rectangle {
                    required property var modelData
                    required property int index
                    width: modelData[0] === "|" ? 10 : 28; height: b.height; color: index === 3 ? "#d98a72" : "transparent"
                    Text { anchors.centerIn: parent; text: parent.modelData[0]; color: "#f0fae8"; font.family: b.icon; font.pixelSize: 17 }
                    MouseArea {
                        anchors.fill: parent; enabled: parent.modelData[1] !== null
                        onClicked: { const a = parent.modelData[1];
                                     if (typeof a === "number") b.act("volumeStep", a);
                                     else if (Array.isArray(a)) b.act("exec", a);
                                     else if (a === "night") b.act("night", !(b.sys?.night)); else b.act(a, null) }
                    }
                }
            }
        }
    }
    Row {
        anchors.right: parent.right; height: parent.height; spacing: 20
        Item_ { text: "wifi " + (b.sys?.online ? (b.sys.wired ? "eth" : "✓") : "x"); onClicked: b.act("wifi", null) }
        Item_ { text: "vol " + (b.sys?.muted ? "mute" : "·".repeat(Math.round((b.sys?.volume ?? 0) * 10)) + " ".repeat(10 - Math.round((b.sys?.volume ?? 0) * 10)))
                onClicked: b.act("mute", null) }
        Rectangle { height: parent.height; width: bat.implicitWidth + 24; color: "#c06a52"
                    Text { id: bat; anchors.centerIn: parent; text: "bat " + ((b.sys?.battery ?? 1) * 100).toFixed(1); color: "#f0fae8"; font.family: "Montserrat Light"; font.pixelSize: 18 } }
    }
    WheelHandler { onWheel: e => b.act("volumeStep", e.angleDelta.y > 0 ? 0.05 : -0.05) }
}
