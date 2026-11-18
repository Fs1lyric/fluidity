// Polestar's desktop clock (Desktop/Screen.vue): bottom-left, "EEE d. MMMM" in muted lilac over a huge
// "hh:mm AP" in Figtree SemiBold.
import QtQuick

Column {
    id: c
    property date now: new Date()
    spacing: 4
    Text { text: Qt.formatDateTime(c.now, "ddd d. MMMM"); font.family: "Figtree"; font.weight: Font.Medium; font.pixelSize: 30; color: "#a095b2" }
    Text { text: Qt.formatDateTime(c.now, "hh:mm AP"); font.family: "Figtree"; font.weight: Font.DemiBold; font.pixelSize: 96; color: "#f4f3f6" }
}
