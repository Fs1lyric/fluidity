import QtQuick

Row {
    property var keys: []
    property bool on: false
    property var pal: ({})
    spacing: 4
    Repeater { model: parent.keys; Key { text: modelData; on: parent.on; pal: parent.pal } }
}
