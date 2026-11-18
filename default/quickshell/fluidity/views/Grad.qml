import QtQuick

// The accent pill: accent to mint, left to right. Used for every selection.
Rectangle {
    property var pal: ({})
    radius: 18
    gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0; color: pal.accent || "#d7e59b" }
        GradientStop { position: 1; color: pal.cyan || "#c2e6d6" }
    }
}
