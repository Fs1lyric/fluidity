import QtQuick

// The guide: Fluidity's own help + settings. Pages on the left; the page's text, its keys and its actions
// on the right. ↑ ↓ pick a page, → / tab into its actions, ↵ runs one, ← back.
AppBase {
    id: a
    readonly property var pages: d.pages || []
    readonly property var page: pages[d.page || 0] || ({})
    readonly property bool inActions: d.focus === "actions"
    Text { x: 24; y: 16; text: "Guide"; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 30 }
    AppList {
        x: 12; y: 62; width: 230; rowH: 46
        pal: a.pal; animate: a.animate; sel: a.inActions ? -1 : (a.d.page || 0)
        rows: a.pages.map((p, i) => ({ icon: p.icon, title: p.title, on: a.inActions && i === (a.d.page || 0) }))
        onPicked: i => a.picked(i)
    }
    Rectangle {
        x: 258; y: 20; width: parent.width - 278; height: parent.height - 40; radius: 22; color: a.faint
        Column {
            anchors.fill: parent; anchors.margins: 20; spacing: 14
            Text { text: a.page.title || ""; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 26 }
            Text { width: parent.width; wrapMode: Text.WordWrap; text: a.page.body || ""; color: a.alpha(a.pal.fg, 0.8); font.family: a.sans; font.pixelSize: 14; lineHeight: 1.3 }
            Repeater {
                model: a.page.keys || []
                Item { width: parent.width; height: 26
                    Text { anchors.verticalCenter: parent.verticalCenter; text: modelData.desc; color: a.pal.dim; font.family: a.sans; font.pixelSize: 13 }
                    KeyRow { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; keys: modelData.keys; pal: a.pal } }
            }
            Flow {
                width: parent.width; spacing: 8
                Repeater {
                    model: a.page.actions || []
                    Rectangle {
                        readonly property bool lit: a.inActions && index === a.sel
                        height: 38; width: at.implicitWidth + 32; radius: 19; color: lit ? "transparent" : Qt.rgba(1, 1, 1, 0.07)
                        Grad { anchors.fill: parent; radius: 19; pal: a.pal; visible: parent.lit }
                        Text { id: at; anchors.centerIn: parent; text: modelData.label; color: parent.lit ? a.ink : a.pal.fg; font.family: a.sans; font.pixelSize: 13; font.weight: Font.Medium }
                    }
                }
            }
        }
    }
}
