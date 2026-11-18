// Axarva's dotfiles-2.0 (eww-1920/eww.scss) colours and glyphs. Nerd Font v2 Material codepoints are mapped to
// v3 (0xF0001 + old - 0xF500); Feather glyphs come from his bundled feather.ttf.
.pragma library
var bg = "#121212", fg = "#ffd5cd", red = "#d35d6e", purple = "#c47eb7", blue = "#84afdb", green = "#90c861",
    trough = "#4e4e4e", search = "#272626", quote = "#a5b3c0", lav = "#b4a5f5";
var sans = "Nunito Sans", icons = "Iosevka Nerd Font", feather = "feather";
function g(cp) { return String.fromCodePoint(cp); }
function v2(cp) { return String.fromCodePoint(cp >= 0xf500 && cp <= 0xfd46 ? 0xf0001 + cp - 0xf500 : cp); }
var fe = { power: 0xe9c0, reboot: 0xe9c4, lock: 0xe98f, suspend: 0xe9a3, logout: 0xe991 };
// his xmonad workspace names (xmonad.hs myWorkspaces)
var workspaces = [0xf66b, 0xf738, 0xf74a, 0xf11b, 0xf683, 0xf871, 0xf79f, 0xf111, 0xf1bc];
// weather: nerd weather glyph + his "side" quotes, picked from the wttr condition
function weather(cond, night) {
    var c = (cond || "").toLowerCase();
    if (/thunder|storm/.test(c)) return [0xe31d, "Stormy out there", "Stay inside and keep warm."];
    if (/snow|sleet|ice/.test(c)) return [0xe31a, "It's snowing", "Hot cocoa and a blanket, maybe?"];
    if (/rain|drizzle|shower/.test(c)) return [0xe318, "It's raining", "A good day for a book."];
    if (/mist|fog|haze|smoke|dust|sand/.test(c)) return [0xe313, "Misty " + (night ? "night" : "day"), "Take it slow out there."];
    if (/cloud|overcast/.test(c)) return [night ? 0xe37e : 0xe302, "It's a cloudy " + (night ? "night" : "day"),
        night ? "How about some hot chocolate and a warm bed?" : "Good weather for focus."];
    return [night ? 0xe32b : 0xe30d, night ? "Clear night" : "It's sunny", night ? "Look at the stars." : "Go touch some grass."];
}
