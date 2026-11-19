// wttr.in's three-day forecast (location from your IP), every 30 minutes: [{ day, max, min, code }]
import QtQuick
import Quickshell.Io

Item {
    id: f
    property var days: []
    Process {
        id: q
        command: ["curl", "-s", "--max-time", "10", "https://wttr.in/Dhaka?format=j1"]
        stdout: StdioCollector { onStreamFinished: { try {
            f.days = JSON.parse(text).weather.map(w => ({ day: new Date(w.date + "T12:00:00"), max: w.maxtempC, min: w.mintempC,
                                                        code: +w.hourly[4].weatherCode })) } catch (e) {} } }
    }
    Timer { interval: 1800000; running: true; repeat: true; triggeredOnStart: true; onTriggered: q.running = true }
}
