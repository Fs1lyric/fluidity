// The startup splash (his bin/startup/w_popup: figlet -f 3d "WELCOME BACK GABE" | lolcat inside a cyan-edged
// kitty window that grows from the middle). Here it says WELCOME BACK and your user name, grows in, holds,
// and fades. Shown once when the shell starts and again on Super+F2.
import QtQuick

Rectangle {
    id: s
    property string name: "GABE"
    property real grow: 1            // 0..1, the window opening like his bspc resize loop
    implicitWidth: 1300; implicitHeight: 700
    color: "#e6262338"; border.color: "#00ffff"; border.width: 1
    width: implicitWidth * (0.35 + 0.65 * grow); height: implicitHeight * (0.2 + 0.8 * grow)
    Column {
        anchors.centerIn: parent; spacing: 20; opacity: s.grow
        PixelText { anchors.horizontalCenter: parent.horizontalCenter; text: "WELCOME"; cell: 18; hueFrom: 0.9; hueSpan: 0.4 }
        PixelText { anchors.horizontalCenter: parent.horizontalCenter; text: "BACK"; cell: 18; hueFrom: 0.72; hueSpan: 0.25 }
        PixelText { anchors.horizontalCenter: parent.horizontalCenter; text: s.name; cell: 18; hueFrom: 0.55; hueSpan: 0.22 }
    }
}
