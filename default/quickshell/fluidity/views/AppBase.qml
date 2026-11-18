import QtQuick

// The base of every Fluid showcase app drawn inside the island (CalendarApp, MediaApp, ...).
// Pure: the shell (Apps.qml) fills `d`; `sel` is the keyboard selection. Clicking a row emits picked(i).
Item {
    property var pal: ({})
    property bool animate: true
    property var d: ({})
    property int sel: 0
    signal picked(int i)
    readonly property string ink: "#101316"
    readonly property string sans: "Geist"
    readonly property string serif: "Instrument Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property color faint: Qt.rgba(1, 1, 1, 0.05)
    function alpha(c, a) { const q = Qt.color(c || "#ffffff"); return Qt.rgba(q.r, q.g, q.b, a) }
}
