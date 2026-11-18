// Bruteon colours (sampled from Darkkal44's previews) and helpers.
.pragma library
var ink = "#1a1414", paper = "#efe3d8", paper2 = "#f6eee8", orange = "#f6a37f", green = "#b8e3a3", pink = "#f8c3d2",
    lav = "#d9bdf5", blue = "#a8c8f5", yellow = "#f6d48b", red = "#f28b82", dim = "#8a7d74";
var mono = "JetBrainsMono Nerd Font";
function g(cp) { return String.fromCodePoint(cp); }
function mmss(s) { s = Math.max(0, Math.round(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0"); }
