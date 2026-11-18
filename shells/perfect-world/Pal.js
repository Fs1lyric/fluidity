// amarena (elenapan/dotfiles .xfiles/amarena) + Nerd Font (Material Design) glyphs standing in for her icomoon set.
.pragma library
var bg = "#1a2026", c0 = "#242d35", c1 = "#fb6396", c2 = "#94cf95", c3 = "#f692b2", c4 = "#6ec1d6",
    c5 = "#cd84c8", c6 = "#7fe4d2", c7 = "#ffffff", c8 = "#526170", c9 = "#f92d72", c10 = "#6ccb6e",
    c11 = "#f26190", c12 = "#4cb9d6", c13 = "#c269bc", c14 = "#58d6bf", fg = "#ffffff";
var sans = "Google Sans", icons = "Iosevka Nerd Font", mono = "Iosevka Nerd Font";
function g(cp) { return String.fromCodePoint(cp); }
var glyph = {
    sun: 0xf0599, cloud: 0xf0590, partly: 0xf0595, rain: 0xf0597, snow: 0xf0598, fog: 0xf0591, storm: 0xf0593,
    moon: 0xf0594, prev: 0xf0141, next: 0xf0142, note: 0xf075a, search: 0xf0349, bolt: 0xf140b,
    bell: 0xf009a, bellOff: 0xf009b, camera: 0xf0100, disk: 0xf01bc, cases: 0xf0004, deaths: 0xf068c,
    uptime: 0xf0379, power: 0xf0425, reboot: 0xf0709, sleep: 0xf04b2, logout: 0xf0343, lock: 0xf033e,
    terminal: 0xf018d, browser: 0xf059f, firefox: 0xf0239, chat: 0xf066f, music: 0xf075a, calendar: 0xf00ed,
    notes: 0xf082e, folder: 0xf024b, image: 0xf02e9, code: 0xf0a1e, mail: 0xf01ee, game: 0xf04d3, app: 0xf08c6
};
// her dock: icon + colour per window class (icons/init.lua), extended with the apps on this machine
var classes = [
    [/kitty|alacritty|ghostty|foot|termite|st-256/i, "terminal", c5], [/zen|firefox/i, "firefox", c3],
    [/chrom|helium|brave/i, "browser", c4], [/vesktop|discord|webcord/i, "chat", c5], [/telegram/i, "chat", c4],
    [/spotify|mpv|music/i, "music", c6], [/calendio|calendar/i, "calendar", c2], [/obsidian|notes|jotter/i, "notes", c2],
    [/thunar|nemo|nautilus|files|burrow/i, "folder", c3], [/feh|sxiv|imv|loupe|gimp/i, "image", c1],
    [/code|nvim|emacs|editor|margin/i, "code", c5], [/mail|thunderbird/i, "mail", c6], [/steam|lutris/i, "game", c2]
];
function classIcon(cls) {
    for (var i = 0; i < classes.length; i++) if (classes[i][0].test(cls)) return { glyph: g(glyph[classes[i][1]]), color: classes[i][2] };
    return { glyph: g(glyph.app), color: "#99ffffff" };
}
