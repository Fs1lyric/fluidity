// Keyboard driving for a panel (batch 4 is keyboard-only: the mouse is never needed). The panel lists its
// controls as rows of ids; arrows or hjkl move the selection, Enter/Space presses it, Left/Right on an id in
// `sliders` nudges it instead, Tab/Shift+Tab walk every control in order, Esc closes.
// Pure QtQuick, so the off-screen previews can draw a selection too.
import QtQuick

Item {
    id: nav
    property var rows: []          // [["prev", "play", "next"], ["wifi", "bt"], ...]
    property var sliders: []       // ids that Left/Right change instead of leaving
    property bool always: false    // previews: draw the selection without keyboard focus
    property int row: 0
    property int col: 0
    readonly property string current: rows.length ? (rows[Math.min(row, rows.length - 1)] ?? [])[col] ?? "" : ""
    signal press(string id)
    signal nudge(string id, int dir)
    signal close()
    function isSel(id) { return (activeFocus || always) && current === id }
    function moveRow(d) { row = Math.max(0, Math.min(rows.length - 1, row + d)); col = Math.min(col, rows[row].length - 1) }
    function moveCol(d) {
        if (sliders.indexOf(current) >= 0) { nudge(current, d); return }
        col = Math.max(0, Math.min(rows[row].length - 1, col + d))
    }
    function step(d) {
        const flat = []; rows.forEach((r, ri) => r.forEach((_, ci) => flat.push([ri, ci])))
        let i = flat.findIndex(p => p[0] === row && p[1] === col) + d
        i = (i + flat.length) % flat.length; row = flat[i][0]; col = flat[i][1]
    }
    Keys.onPressed: e => {
        switch (e.key) {
        case Qt.Key_Up: case Qt.Key_K: moveRow(-1); break
        case Qt.Key_Down: case Qt.Key_J: moveRow(1); break
        case Qt.Key_Left: case Qt.Key_H: moveCol(-1); break
        case Qt.Key_Right: case Qt.Key_L: moveCol(1); break
        case Qt.Key_Tab: step(1); break
        case Qt.Key_Backtab: step(-1); break
        case Qt.Key_Return: case Qt.Key_Enter: case Qt.Key_Space: press(current); break
        case Qt.Key_Escape: case Qt.Key_Q: close(); break
        default: return
        }
        e.accepted = true
    }
}
