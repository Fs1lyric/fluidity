import QtQuick

// Wellbeing: today's screen time (from fluidity-wellbeing, one sample a minute, kept on this PC), the day by
// hour, the apps you spent it in, and how long since your last break. r refreshes.
AppBase {
    id: a
    function hm(m) { m = m || 0; return m >= 60 ? Math.floor(m / 60) + "h " + (m % 60) + "m" : m + "m" }
    readonly property var apps: (d.apps || []).slice(0, 5)
    readonly property int most: Math.max(1, ...(apps.map(x => x.minutes)))
    readonly property int peak: Math.max(1, ...((d.hours || [0])))
    Row {
        x: 24; y: 18; spacing: 14
        Text { text: a.hm(a.d.total); color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 44 }
        Column { anchors.bottom: parent.bottom; anchors.bottomMargin: 8
            Text { text: "screen time today"; color: a.pal.dim; font.family: a.sans; font.pixelSize: 13 }
            Text { text: (a.d.streak || 0) >= (a.d.breakAfter || 50) ? "take a break, " + a.hm(a.d.streak) + " straight" : a.hm(a.d.streak) + " since your last break"
                color: (a.d.streak || 0) >= (a.d.breakAfter || 50) ? a.pal.orange : a.pal.accent; font.family: a.sans; font.pixelSize: 13; font.weight: Font.Medium } }
    }
    Row { // by hour
        x: 24; y: 92; height: 90; spacing: 4
        Repeater {
            model: a.d.hours || []
            Column {
                anchors.bottom: parent.bottom; spacing: 4
                Rectangle { width: (a.width - 48 - 23 * 4) / 24; height: Math.max(3, 70 * modelData / a.peak); radius: 3
                    color: index === a.d.now ? a.pal.accent : a.alpha(a.pal.cyan, modelData ? 0.55 : 0.12) }
                Text { width: (a.width - 48 - 23 * 4) / 24; horizontalAlignment: Text.AlignHCenter; text: index % 6 === 0 ? index : ""; color: a.pal.dim; font.family: a.mono; font.pixelSize: 10 }
            }
        }
    }
    Column { // by app
        x: 24; y: 200; width: parent.width - 48; spacing: 10
        Text { visible: !a.apps.length; text: "Nothing yet today. Samples start a minute after login."; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
        Repeater {
            model: a.apps
            Item {
                width: parent.width; height: 26
                Text { width: 120; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter; text: modelData.app; color: a.pal.fg; font.family: a.sans; font.pixelSize: 14 }
                Rectangle { x: 130; width: (parent.width - 210) * modelData.minutes / a.most; height: 10; radius: 5; anchors.verticalCenter: parent.verticalCenter
                    gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: a.pal.accent } GradientStop { position: 1; color: a.pal.cyan } } }
                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: a.hm(modelData.minutes); color: a.pal.dim; font.family: a.mono; font.pixelSize: 12 }
            }
        }
    }
}
