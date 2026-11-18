-- Fluidity's Hyprland defaults. ~/.config/hypr/hyprland.lua loads this, then your own files, then the
-- theme's hyprland-final.lua. The repo owns everything in here; your edits go in ~/.config/hypr.
FLUIDITY = FLUIDITY or os.getenv("FLUIDITY_PATH") or (os.getenv("HOME") .. "/.local/share/fluidity")

require("hypr.helpers")
require("hypr.autostart")
require("hypr.require_all").files("bindings", "hypr.bindings")
require("hypr.envs")
require("hypr.looknfeel")
require("hypr.liquid")
require("hypr.layers")
require("hypr.input")
require("hypr.windows")
require("hypr.theme").load_own()
