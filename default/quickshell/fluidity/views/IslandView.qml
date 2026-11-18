import QtQuick

// The island: one glass shape that grows into every popup (PLAN.md "Look: Liquid").
// Pure view: no Quickshell types, so tools/render.py can draw it off-screen.
// The shell sets `view` and the data for it; the island springs to the new size and fades the content in.
Item {
    id: root

    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", blue: "#a9b8e8", red: "#f2a7a7", fg: "#e3e4da", dim: "#878880", muted: "#3a3f45", bg: "#111417", yellow: "#e8d98a", magenta: "#c8a8e0", orange: "#f0c08a" })
    property bool animate: true
    property string view: "idle"
    property int index: 0
    property string query: ""
    property string placeholder: ""

    // idle
    property string song: ""
    property bool playing: false
    property string clock: ""
    // launcher / clipboard / cheatsheet / switcher / wallpaper / power / leader / emoji / control: list data
    property var items: []
    property var groups: []        // cheatsheet: [{name, binds:[{desc, keys:[]}]}]
    property var preview: ({})     // clipboard: {kind, text, src, info}
    property var calc: null        // launcher: {expr, result}
    property var cats: []          // emoji categories
    property int cat: 0
    property string title: ""      // leader row name, wallpaper name, notify title
    property string body: ""
    property string icon: ""
    property real value: 0         // osd 0..1
    property var keyHint: []
    property string extra: ""          // idle: focus countdown or the next Calendio block (accent)
    property Component thumbDelegate: null   // switcher: the shell gives live window thumbnails
    property var app: ({})             // a showcase app's data (Apps.qml)
    property int screenW: 1920         // the idle screen fills it
    property int screenH: 1080

    // the Fluid showcase apps: one file each, on AppBase
    readonly property var appFiles: ({ calendar: "CalendarApp.qml", media: "MediaApp.qml", network: "NetworkApp.qml", bluetooth: "BluetoothApp.qml", syspanel: "SysApp.qml", quickactions: "QuickApp.qml", wellbeing: "WellbeingApp.qml", guide: "GuideApp.qml", widgets: "WidgetsApp.qml", polkit: "PolkitApp.qml", idlescreen: "IdleScreenApp.qml" })
    readonly property bool isApp: !!appFiles[view]
    readonly property bool known: view === "idle" || !!sizes[view]

    readonly property string ink: "#101316"
    readonly property string sans: "Geist"
    readonly property string serif: "Instrument Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"

    // width, height, corner radius per view
    readonly property var sizes: ({
        idle: [360 + (song ? 0 : -120) + (extra ? 150 : 0), 40, 20], launcher: [640, calc ? 420 : 372, 30], emoji: [600, 318, 30], clipboard: [960, 396, 30],
        cheatsheet: [1240, 56 + 30 + 38 * groups.reduce((m, g) => Math.max(m, (g.binds || []).length), 1) + 22, 30], leader: [1320, 64, 32], power: [520, 120, 40], wallpaper: [1240, 250, 30],
        switcher: [Math.max(360, 48 + items.length * 226), 210, 30], notify: [520, 80, 28], osd: [420, 52, 26],
        hints: [420, 52, 24], control: [640, 240 + (song ? 26 : 0), 30], notifications: [560, 420, 30],
        calendar: [900, 440, 32], media: [980, app.title ? 310 : 90, 32],
        network: [620, 64 + 50 * Math.max(1, Math.min(7, (app.nets || []).length)) + (app.ask ? 84 : 16), 30],
        bluetooth: [620, 64 + 50 * Math.max(1, Math.min(7, (app.devs || []).length)) + 16, 30],
        syspanel: [620, 306 + 50 * (app.sliders || []).length + 12, 30], quickactions: [640, 64 + 80 * Math.ceil((app.tiles || []).length / 3) + 76, 32],
        wellbeing: [640, 200 + 36 * Math.max(1, Math.min(5, (app.apps || []).length)) + 14, 30], guide: [900, Math.max(400, 62 + 46 * (app.pages || []).length + 20), 30],
        widgets: [560, 62 + 46 * 8 + 12, 30], polkit: [620, app.error ? 190 : 170, 30], idlescreen: [screenW - 28, screenH - 28, 60]
    })
    readonly property var size: sizes[view] || sizes.idle

    width: size[0]; height: size[1]
    Behavior on width { enabled: root.animate; SpringAnimation { spring: 4.2; damping: 0.32; epsilon: 0.4 } }
    Behavior on height { enabled: root.animate; SpringAnimation { spring: 4.2; damping: 0.32; epsilon: 0.4 } }

    signal activated(int index)

    Glass {
        id: shape
        anchors.fill: parent
        pal: root.pal
        radius: root.size[2]
        glow: root.view !== "idle"
        tint: 0.88
        Behavior on radius { enabled: root.animate; NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

        Loader {
            id: appContent
            anchors.fill: parent
            clip: true
            active: root.isApp
            source: root.isApp ? root.appFiles[root.view] : ""
            onLoaded: {
                item.pal = Qt.binding(() => root.pal); item.animate = Qt.binding(() => root.animate)
                item.d = Qt.binding(() => root.app); item.sel = Qt.binding(() => root.index)
                item.picked.connect(i => root.activated(i))
                if (root.animate) { opacity = 0; appFade.restart() }
            }
            NumberAnimation { id: appFade; target: appContent; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
        }
        Loader {
            id: content
            anchors.fill: parent
            clip: true
            active: !root.isApp
            sourceComponent: ({ idle: idleV, launcher: launcherV, emoji: emojiV, clipboard: clipV, cheatsheet: cheatV,
                leader: leaderV, power: powerV, wallpaper: wallV, switcher: switchV, notify: notifyV, osd: osdV,
                hints: hintsV, control: controlV, notifications: historyV })[root.view] || idleV
            opacity: 1
            onSourceComponentChanged: if (root.animate) { opacity = 0; fade.restart() }
            NumberAnimation { id: fade; target: content; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
        }
    }

    // ---------- shared pieces ----------
    Component {
        id: searchRow
        Row {
            spacing: 12
            height: 56; leftPadding: 24; rightPadding: 24
            Rectangle { width: 12; height: 12; radius: 6; color: root.pal.accent; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.query || root.placeholder; color: root.query ? root.pal.fg : root.pal.dim; font.family: root.sans; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 2; height: 24; radius: 1; color: root.pal.accent; anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity { running: root.animate; loops: Animation.Infinite; NumberAnimation { to: 0; duration: 500 } NumberAnimation { to: 1; duration: 500 } } }
        }
    }
    // a list with the sliding accent pill behind the selected row
    Component {
        id: rowList
        Item {
            id: rl
            property var rows: []
            property int sel: 0
            property int rowH: 52
            height: rows.length * rowH
            Grad {
                pal: root.pal
                x: 12; width: parent.width - 24; height: rl.rowH
                y: rl.sel * rl.rowH
                visible: rl.rows.length > 0
                Behavior on y { enabled: root.animate; SpringAnimation { spring: 5; damping: 0.34; epsilon: 0.3 } }
            }
            Repeater {
                model: rl.rows
                Item {
                    readonly property bool on: index === rl.sel
                    x: 12; y: index * rl.rowH; width: rl.width - 24; height: rl.rowH
                    Rectangle {
                        id: ic
                        x: 12; width: 32; height: 32; radius: 11; anchors.verticalCenter: parent.verticalCenter
                        color: parent.on ? Qt.rgba(0.06, 0.07, 0.09, 0.12) : Qt.rgba(1, 1, 1, 0.06)
                        Text { anchors.centerIn: parent; visible: !modelData.image; text: modelData.icon || ""; font.family: root.mono; font.pixelSize: 15; color: parent.parent.on ? root.ink : (modelData.iconColor || root.pal.fg) }
                        Image { anchors.fill: parent; anchors.margins: 4; visible: !!modelData.image; source: modelData.image || ""; sourceSize.width: 48; sourceSize.height: 48; smooth: true; asynchronous: true }
                    }
                    Column {
                        anchors.left: ic.right; anchors.leftMargin: 14; anchors.right: meta.left; anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        Text { width: parent.width; elide: Text.ElideRight; text: modelData.title || ""; color: parent.parent.on ? root.ink : root.pal.fg; font.family: root.sans; font.pixelSize: 15; font.weight: Font.Medium }
                        Text { visible: !!modelData.desc; width: parent.width; elide: Text.ElideRight; text: modelData.desc || ""; color: parent.parent.on ? Qt.rgba(0.06, 0.07, 0.09, 0.6) : root.pal.dim; font.family: root.sans; font.pixelSize: 12 }
                    }
                    Item {
                        id: meta
                        anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(k.width, m.width); height: 22
                        KeyRow { id: k; anchors.right: parent.right; keys: modelData.keys || []; on: parent.parent.on; pal: root.pal }
                        Text { id: m; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; visible: !modelData.keys; text: modelData.meta || ""; color: parent.parent.on ? Qt.rgba(0.06, 0.07, 0.09, 0.6) : root.pal.dim; font.family: root.mono; font.pixelSize: 12 }
                    }
                }
            }
        }
    }
    Component {
        id: footer
        Row {
            spacing: 18; leftPadding: 24; height: 36
            Repeater { model: root.keyHint; Text { text: modelData; color: root.pal.dim; font.family: root.sans; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter } }
        }
    }

    // ---------- views ----------
    Component {
        id: idleV
        Item { Row {
            anchors.centerIn: parent
            spacing: 14
            Row {
                spacing: 2; height: 14; anchors.verticalCenter: parent.verticalCenter
                visible: root.song !== ""
                Repeater {
                    model: 5
                    Rectangle {
                        width: 3; radius: 1.5; anchors.verticalCenter: parent.verticalCenter
                        color: [root.pal.accent, root.pal.cyan, root.pal.accent, root.pal.red, root.pal.accent][index]
                        height: 6
                        SequentialAnimation on height {
                            running: root.animate && root.playing; loops: Animation.Infinite
                            PauseAnimation { duration: index * 90 }
                            NumberAnimation { to: 14; duration: 420; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 4; duration: 420; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }
            Text { visible: root.song !== ""; text: root.song; color: root.pal.dim; font.family: root.sans; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight; width: Math.min(implicitWidth, 170) }
            Rectangle { visible: root.song !== ""; width: 4; height: 4; radius: 2; color: root.pal.muted; anchors.verticalCenter: parent.verticalCenter }
            Text { visible: root.extra !== ""; text: root.extra; elide: Text.ElideRight; width: Math.min(implicitWidth, 230); color: root.pal.accent; font.family: root.sans; font.pixelSize: 13; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { visible: root.extra !== ""; width: 4; height: 4; radius: 2; color: root.pal.muted; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.clock; color: root.pal.fg; font.family: root.sans; font.pixelSize: 13; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter }
        } }
    }

    Component {
        id: launcherV
        Column {
            topPadding: 2
            Loader { sourceComponent: searchRow }
            Loader { width: parent.width; sourceComponent: rowList; onLoaded: { item.rows = Qt.binding(() => root.items.slice(0, 5)); item.sel = Qt.binding(() => root.index) } }
            Item { width: 1; height: 8 }
            Rectangle {
                visible: !!root.calc; x: 20; width: parent.width - 40; height: 40; radius: 16; color: Qt.rgba(1, 1, 1, 0.04)
                Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: root.calc ? "= " + root.calc.expr : ""; color: root.pal.dim; font.family: root.mono; font.pixelSize: 13 }
                Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: root.calc ? root.calc.result : ""; color: root.pal.accent; font.family: root.mono; font.pixelSize: 13 }
            }
            Loader { sourceComponent: footer }
        }
    }

    Component {
        id: emojiV
        Column {
            Loader { sourceComponent: searchRow }
            Row {
                leftPadding: 18; spacing: 4; height: 40
                Repeater {
                    model: root.cats
                    Rectangle {
                        height: 28; width: ct.implicitWidth + 18; radius: 14
                        color: index === root.cat ? root.pal.accent : Qt.rgba(1, 1, 1, 0.05)
                        Text { id: ct; anchors.centerIn: parent; text: modelData; color: index === root.cat ? root.ink : root.pal.dim; font.family: root.sans; font.pixelSize: 12 }
                    }
                }
            }
            Grid {
                id: eg
                x: 18; columns: 10; spacing: 4
                readonly property real cell: (parent.width - 36 - 9 * 4) / 10
                Repeater {
                    model: root.items.slice(0, 30)
                    Item {
                        width: eg.cell; height: eg.cell
                        readonly property bool on: index === root.index
                        Rectangle {
                            anchors.centerIn: parent; width: parent.width; height: width; radius: width / 2
                            visible: parent.on
                            color: Qt.rgba(Qt.color(root.pal.accent).r, Qt.color(root.pal.accent).g, Qt.color(root.pal.accent).b, 0.25)
                            border.width: 2; border.color: root.pal.accent
                        }
                        Text { anchors.centerIn: parent; text: modelData.e; font.pixelSize: parent.on ? 30 : 25; font.family: "Noto Color Emoji"
                            Behavior on font.pixelSize { enabled: root.animate; NumberAnimation { duration: 200; easing.type: Easing.OutBack } } }
                    }
                }
            }
            Item {
                width: parent.width; height: 48
                Text { x: 26; anchors.verticalCenter: parent.verticalCenter; text: (root.items[root.index] || {}).name || ""; color: root.pal.fg; font.family: root.serif; font.italic: true; font.pixelSize: 24 }
                Text { anchors.right: parent.right; anchors.rightMargin: 26; anchors.verticalCenter: parent.verticalCenter; text: "↵ paste · ⇧↵ skin tone"; color: root.pal.dim; font.family: root.mono; font.pixelSize: 12 }
            }
        }
    }

    Component {
        id: clipV
        Column {
            Loader { sourceComponent: searchRow }
            Row {
                width: parent.width
                Loader { width: parent.width / 2; sourceComponent: rowList; onLoaded: { item.rows = Qt.binding(() => root.items.slice(0, 6)); item.sel = Qt.binding(() => root.index) } }
                Rectangle {
                    width: parent.width / 2 - 16; height: 300; radius: 22; color: Qt.rgba(1, 1, 1, 0.035)
                    Column {
                        anchors.fill: parent; anchors.margins: 16; spacing: 10
                        Text { text: root.preview.info || ""; color: root.pal.dim; font.family: root.sans; font.pixelSize: 12 }
                        Rectangle {
                            visible: root.preview.kind !== "image"
                            width: parent.width; height: Math.min(220, pv.implicitHeight + 24); radius: 16; color: Qt.rgba(0, 0, 0, 0.35); clip: true
                            Text { id: pv; x: 14; y: 12; width: parent.width - 28; text: root.preview.text || ""; color: root.pal.fg; font.family: root.mono; font.pixelSize: 13; wrapMode: Text.WrapAnywhere; lineHeight: 1.25 }
                        }
                        Image {
                            visible: root.preview.kind === "image"
                            width: parent.width; height: 200; fillMode: Image.PreserveAspectCrop; source: root.preview.src || ""; asynchronous: true
                        }
                    }
                }
            }
        }
    }

    Component {
        id: cheatV
        Column {
            Loader { sourceComponent: searchRow }
            Row {
                x: 12; spacing: 6
                Repeater {
                    model: root.groups
                    Column {
                        width: (1240 - 24 - 18) / 4
                        Text { leftPadding: 14; topPadding: 6; bottomPadding: 4; text: modelData.name.toUpperCase(); color: root.pal.dim; font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2 }
                        Repeater {
                            model: modelData.binds
                            Rectangle {
                                readonly property bool on: !!modelData.on
                                width: parent.width; height: 38; radius: 14
                                color: "transparent"
                                Grad { anchors.fill: parent; radius: 14; pal: root.pal; visible: parent.on }
                                Text { x: 14; anchors.verticalCenter: parent.verticalCenter; width: parent.width - kk.width - 40; elide: Text.ElideRight; text: modelData.desc; color: parent.on ? root.ink : root.pal.fg; font.family: root.sans; font.pixelSize: 14 }
                                KeyRow { id: kk; anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; keys: modelData.keys; on: parent.on; pal: root.pal }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: leaderV
        Item { Row {
            anchors.verticalCenter: parent.verticalCenter
            leftPadding: 12; spacing: 12
            Grad {
                pal: root.pal; height: 36; width: lt.implicitWidth + 40; radius: 18; anchors.verticalCenter: parent.verticalCenter
                Row { anchors.centerIn: parent; spacing: 8
                    Rectangle { width: 10; height: 10; radius: 5; color: root.ink; anchors.verticalCenter: parent.verticalCenter }
                    Text { id: lt; text: root.title || "❖ ;"; color: root.ink; font.family: root.sans; font.pixelSize: 13; font.weight: Font.DemiBold } }
            }
            Repeater {
                model: root.items
                Row {
                    spacing: 6; anchors.verticalCenter: parent.verticalCenter
                    Rectangle { width: 26; height: 26; radius: 13; color: Qt.rgba(1, 1, 1, 0.08)
                        Text { anchors.centerIn: parent; text: modelData.k; color: root.pal.fg; font.family: root.mono; font.pixelSize: 12; font.weight: Font.DemiBold } }
                    Text { text: modelData.label; color: root.pal.dim; font.family: root.sans; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        } }
    }

    Component {
        id: powerV
        Item { Row {
            anchors.centerIn: parent; spacing: 12
            Repeater {
                model: root.items
                Rectangle {
                    readonly property bool on: index === root.index
                    height: 72; radius: 36
                    width: on ? 168 : 72
                    Behavior on width { enabled: root.animate; SpringAnimation { spring: 4.5; damping: 0.33 } }
                    color: on ? "transparent" : Qt.rgba(1, 1, 1, 0.06)
                    Grad { anchors.fill: parent; radius: 36; pal: ({ accent: modelData.danger ? root.pal.red : root.pal.accent, cyan: modelData.danger ? root.pal.orange : root.pal.cyan }); visible: parent.on }
                    Row {
                        anchors.centerIn: parent; spacing: 10
                        Text { text: modelData.icon; font.family: root.mono; font.pixelSize: 24; color: parent.parent.on ? root.ink : modelData.danger ? root.pal.red : root.pal.fg }
                        Text { visible: parent.parent.on; text: modelData.label; font.family: root.sans; font.pixelSize: 15; font.weight: Font.DemiBold; color: root.ink; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        } }
    }

    Component {
        id: wallV
        Column {
            leftPadding: 24; topPadding: 20; spacing: 16
            Row {
                spacing: 12
                Text { text: root.title; color: root.pal.fg; font.family: root.serif; font.italic: true; font.pixelSize: 30 }
                Text { text: root.body; color: root.pal.dim; font.family: root.mono; font.pixelSize: 12; anchors.baseline: parent.children[0].baseline }
            }
            Row {
                spacing: 12
                Repeater {
                    model: {
                        const n = root.items.length, out = [];
                        for (let d = -2; d <= 2; d++) if (n) out.push({ i: ((root.index + d) % n + n) % n, on: d === 0 });
                        return out;
                    }
                    Rectangle {
                        width: modelData.on ? 300 : 190; height: width * 9 / 16; radius: 18; clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.pal.bg
                        border.width: modelData.on ? 3 : 0; border.color: root.pal.accent
                        Behavior on width { enabled: root.animate; SpringAnimation { spring: 4.5; damping: 0.33 } }
                        Image { anchors.fill: parent; anchors.margins: parent.border.width; source: (root.items[modelData.i] || {}).src || ""; fillMode: Image.PreserveAspectCrop; asynchronous: true; sourceSize.width: 600; opacity: modelData.on ? 1 : 0.55 }
                    }
                }
            }
        }
    }

    Component {
        id: switchV
        Item { Row {
            anchors.centerIn: parent; spacing: 16
            Repeater {
                model: root.items
                Column {
                    readonly property bool on: index === root.index
                    spacing: 10
                    Rectangle {
                        width: 210; height: 128; radius: 18; color: Qt.rgba(0, 0, 0, 0.4); clip: true
                        border.width: parent.on ? 3 : 1; border.color: parent.on ? root.pal.accent : Qt.rgba(1, 1, 1, 0.06)
                        Image { anchors.fill: parent; anchors.margins: parent.border.width; source: modelData.thumb || ""; fillMode: Image.PreserveAspectCrop; visible: !!modelData.thumb }
                        Loader { anchors.fill: parent; anchors.margins: parent.border.width; active: !!root.thumbDelegate; sourceComponent: root.thumbDelegate; property var win: modelData }
                        Text { anchors.centerIn: parent; visible: !modelData.thumb && !root.thumbDelegate; text: modelData.icon || ""; font.family: root.mono; font.pixelSize: 40; color: parent.parent.on ? root.pal.accent : root.pal.dim }
                    }
                    Text { width: 210; elide: Text.ElideRight; text: (modelData.icon ? modelData.icon + "  " : "") + modelData.title; color: parent.on ? root.pal.accent : root.pal.dim; font.family: root.sans; font.pixelSize: 13 }
                }
            }
        } }
    }

    Component {
        id: notifyV
        Item { Row {
            anchors.verticalCenter: parent.verticalCenter; leftPadding: 18; spacing: 16
            Rectangle {
                width: 48; height: 48; radius: 16; anchors.verticalCenter: parent.verticalCenter
                gradient: Gradient { GradientStop { position: 0; color: root.pal.accent } GradientStop { position: 1; color: root.pal.cyan } }
                Text { anchors.centerIn: parent; text: root.icon || "󰂚"; font.family: root.mono; font.pixelSize: 21; color: root.ink }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter; width: 520 - 18 - 48 - 16 - 24 - (nk.visible ? nk.width + 12 : 0)
                Text { width: parent.width; elide: Text.ElideRight; text: root.title; color: root.pal.fg; font.family: root.sans; font.pixelSize: 15; font.weight: Font.DemiBold }
                Text { width: parent.width; elide: Text.ElideRight; text: root.body; color: root.pal.dim; font.family: root.sans; font.pixelSize: 13 }
            }
            KeyRow { id: nk; visible: root.keyHint.length > 0; keys: root.keyHint; pal: root.pal; anchors.verticalCenter: parent.verticalCenter }
        } }
    }

    Component {
        id: osdV
        Item { Row {
            anchors.verticalCenter: parent.verticalCenter; leftPadding: 20; spacing: 14
            Text { text: root.icon; font.family: root.mono; font.pixelSize: 18; color: root.pal.accent; anchors.verticalCenter: parent.verticalCenter }
            Rectangle {
                width: 420 - 20 - 18 - 14 - 14 - 34 - 20; height: 8; radius: 4; color: Qt.rgba(1, 1, 1, 0.08); anchors.verticalCenter: parent.verticalCenter
                Grad { pal: root.pal; height: parent.height; radius: 4; width: parent.width * Math.max(0, Math.min(1, root.value))
                    Behavior on width { enabled: root.animate; SpringAnimation { spring: 5; damping: 0.4 } } }
            }
            Text { width: 34; horizontalAlignment: Text.AlignRight; text: Math.round(root.value * 100); color: root.pal.fg; font.family: root.serif; font.italic: true; font.pixelSize: 24; anchors.verticalCenter: parent.verticalCenter }
        } }
    }

    Component {
        id: hintsV
        Item { Row {
            anchors.verticalCenter: parent.verticalCenter; leftPadding: 20; spacing: 10
            Text { text: "󰳽"; font.family: root.mono; font.pixelSize: 18; color: root.pal.accent }
            Text { text: root.title; color: root.pal.fg; font.family: root.sans; font.pixelSize: 14 }
        } }
    }

    Component {
        id: controlV
        Column {
            padding: 20; spacing: 14
            Grid {
                columns: 3; spacing: 10
                Repeater {
                    model: root.items
                    Rectangle {
                        readonly property bool sel: index === root.index
                        width: (640 - 40 - 20) / 3; height: 64; radius: 22
                        color: modelData.on ? "transparent" : Qt.rgba(1, 1, 1, 0.05)
                        border.width: sel ? 2 : 0; border.color: root.pal.fg
                        Grad { anchors.fill: parent; radius: 22; pal: root.pal; visible: modelData.on }
                        Row {
                            anchors.verticalCenter: parent.verticalCenter; leftPadding: 16; spacing: 12
                            Text { text: modelData.icon; font.family: root.mono; font.pixelSize: 18; color: modelData.on ? root.ink : root.pal.fg; anchors.verticalCenter: parent.verticalCenter }
                            Column { anchors.verticalCenter: parent.verticalCenter
                                Text { text: modelData.label; color: modelData.on ? root.ink : root.pal.fg; font.family: root.sans; font.pixelSize: 13; font.weight: Font.Medium }
                                Text { text: modelData.state || (modelData.on ? "on" : "off"); color: modelData.on ? Qt.rgba(0.06, 0.07, 0.09, 0.6) : root.pal.dim; font.family: root.sans; font.pixelSize: 11 } }
                        }
                    }
                }
            }
            Repeater {
                model: root.groups   // sliders: [{icon, value}]
                Row {
                    spacing: 14
                    Text { text: modelData.icon; font.family: root.mono; font.pixelSize: 18; color: root.pal.accent; anchors.verticalCenter: parent.verticalCenter; width: 22 }
                    Rectangle { width: 640 - 40 - 22 - 14 - 50; height: 10; radius: 5; color: Qt.rgba(1, 1, 1, 0.08); anchors.verticalCenter: parent.verticalCenter
                        Grad { pal: root.pal; height: parent.height; radius: 5; width: parent.width * modelData.value } }
                    Text { text: Math.round(modelData.value * 100); color: root.pal.fg; font.family: root.serif; font.italic: true; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                }
            }
            Text { visible: root.song !== ""; text: (root.playing ? "󰏤  " : "󰐊  ") + root.song; color: root.pal.dim; font.family: root.sans; font.pixelSize: 13 }
        }
    }

    Component {
        id: historyV
        Column {
            Item { width: parent.width; height: 56
                Text { x: 24; anchors.verticalCenter: parent.verticalCenter; text: "Notifications"; color: root.pal.fg; font.family: root.serif; font.italic: true; font.pixelSize: 26 }
                Text { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; text: root.items.length + " · del clears"; color: root.pal.dim; font.family: root.mono; font.pixelSize: 12 } }
            Loader { width: parent.width; sourceComponent: rowList; onLoaded: { item.rows = Qt.binding(() => root.items.slice(0, 6)); item.sel = Qt.binding(() => root.index); item.rowH = 56 } }
        }
    }
}
