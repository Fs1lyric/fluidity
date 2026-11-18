-- Your Hyprland config. Fluidity's defaults load first, then your files next to this one, then the
-- current theme's last word. `fluidity-update` never touches this folder.
local home = os.getenv("HOME")
FLUIDITY = os.getenv("FLUIDITY_PATH") or (home .. "/.local/share/fluidity")

-- drop cached modules so `hyprctl reload` picks up edits
for module in pairs(package.loaded) do
  if module == "hypr" or module:sub(1, 5) == "hypr." or module:sub(1, 5) == "user." then package.loaded[module] = nil end
end
package.path = FLUIDITY .. "/default/?.lua;" .. home .. "/.config/hypr/?.lua;" .. package.path

require("hypr.init")

-- yours (each file is optional)
for _, name in ipairs({ "monitors", "input", "bindings", "looknfeel", "autostart" }) do
  local path = home .. "/.config/hypr/" .. name .. ".lua"
  if io.open(path, "r") then dofile(path) end
end

-- runtime toggles (gaps, aspect ratio, per-workspace layouts)
require("hypr.toggles")

-- the theme's last word (some themes bring their own gaps, corners and motion)
local final = home .. "/.config/fluidity/theme/hyprland-final.lua"
if io.open(final, "r") then dofile(final) end
