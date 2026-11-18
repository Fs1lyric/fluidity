import QtQuick

// The password prompt for system actions (Fluidity is the polkit agent). Type, ↵ sends, esc cancels.
AppBase {
    id: a
    Rectangle {
        x: 22; y: 22; width: 56; height: 56; radius: 20
        gradient: Gradient { GradientStop { position: 0; color: a.d.error ? a.pal.red : a.pal.accent } GradientStop { position: 1; color: a.d.error ? a.pal.orange : a.pal.cyan } }
        Text { anchors.centerIn: parent; text: "󰌾"; font.family: a.mono; font.pixelSize: 24; color: a.ink }
    }
    Column {
        x: 96; y: 20; width: parent.width - 120; spacing: 4
        Text { text: "Your password, " + (a.d.user || ""); color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 26 }
        Text { width: parent.width; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight; text: a.d.message || ""; color: a.pal.dim; font.family: a.sans; font.pixelSize: 13 }
    }
    Rectangle {
        x: 22; anchors.bottom: parent.bottom; anchors.bottomMargin: a.d.error ? 40 : 20; width: parent.width - 44; height: 50; radius: 20
        color: Qt.rgba(0, 0, 0, 0.35); border.width: 1; border.color: a.alpha(a.d.error ? a.pal.red : a.pal.accent, 0.6)
        Text { x: 34; anchors.verticalCenter: parent.verticalCenter; visible: !(a.d.secret || "").length; text: (a.d.prompt || "Password").replace(/:\s*$/, "") + " · ↵ to confirm · esc cancels"; color: a.pal.dim; font.family: a.sans; font.pixelSize: 13 }
        Text { x: 18; anchors.verticalCenter: parent.verticalCenter; text: (a.d.echo ? (a.d.secret || "") : "•".repeat((a.d.secret || "").length)) + "▏"; color: a.pal.accent; font.family: a.mono; font.pixelSize: 18 }
    }
    Text { visible: !!a.d.error; x: 26; anchors.bottom: parent.bottom; anchors.bottomMargin: 14; text: a.d.error || ""; color: a.pal.red; font.family: a.sans; font.pixelSize: 12 }
}
