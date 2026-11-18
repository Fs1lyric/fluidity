import QtQuick

// Widgets: every desktop widget with its switch. ↑ ↓ pick, ↵ / space flips it (fluidity-widgets flip NAME).
AppBase {
    id: a
    readonly property var labels: ({ clock: ["󰥔", "The big clock"], media: ["󰝚", "Now playing"], agenda: ["󰃭", "Today from Calendio"], system: ["󰍛", "System rings"],
        weather: ["󰖐", "Weather"], github: ["󰊤", "GitHub contributions"], notes: ["󰎚", "Notes (notes.md)"], dock: ["󰞒", "Dock (Fluid theme)"], timer: ["󰔟", "Focus timer"], usage: ["󰚩", "AI usage"],
        battery: ["󰁹", "Battery"], visualizer: ["󰺢", "Visualizer"], user: ["󰀄", "You"], image: ["󰋩", "Image (~/.config/fluidity/widget-image)"], text: ["󰊄", "Text (~/.config/fluidity/widget-text)"] })
    Text { x: 24; y: 16; text: "Widgets"; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 30 }
    Text { anchors.right: parent.right; anchors.rightMargin: 24; y: 28; text: "↵ flips · ❖ ⇧ Space hides all"; color: a.pal.dim; font.family: a.mono; font.pixelSize: 11 }
    Flickable {
        x: 12; y: 62; width: parent.width - 24; height: parent.height - 74; clip: true
        contentHeight: list.height; contentY: Math.max(0, Math.min(contentHeight - height, a.sel * 46 - height / 2 + 23))
        AppList {
            id: list; width: parent.width; rowH: 46
            pal: a.pal; animate: a.animate; sel: a.sel
            rows: (a.d.rows || []).map(r => ({ icon: (a.labels[r.name] || ["", r.name])[0], title: (a.labels[r.name] || ["", r.name])[1], on: r.on, meta: r.on ? "on" : "off", dim: !r.on }))
            onPicked: i => a.picked(i)
        }
    }
}
