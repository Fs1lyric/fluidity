-- Liquid: Fluidity's own feel (PLAN.md "Look: Liquid"). Loaded after looknfeel.lua, before the theme's final word.
-- Round glass windows, a slowly turning accent gradient on the focused border, springy but quick motion.
local theme = require("hypr.theme")
local c = theme.colors()
local function rgba(hex, alpha) return "rgba(" .. hex:sub(2) .. alpha .. ")" end

local LIQUID = {
  rounding = 22,
  gaps_in = 8,
  gaps_out = 16,
  border_size = 2,
}

hl.config({
  general = {
    gaps_in = LIQUID.gaps_in,
    gaps_out = LIQUID.gaps_out,
    border_size = LIQUID.border_size,
    col = {
      -- accent, mint, blue, pink: the gradient the showcase mockup turns
      active_border = { colors = { rgba(c.accent, "ff"), rgba(c.cyan, "ff"), rgba(c.blue, "ff"), rgba(c.red, "ff") }, angle = 45 },
      inactive_border = rgba(c.background, "00"),
    },
  },
  decoration = {
    rounding = LIQUID.rounding,
    rounding_power = 2.6, -- a touch of squircle
    active_opacity = 0.92,
    inactive_opacity = 0.86,
    shadow = { enabled = true, range = 40, render_power = 3, color = "rgba(00000066)", offset = { 0, 12 } },
    blur = { enabled = true, size = 12, passes = 3, noise = 0.03, vibrancy = 0.4, contrast = 1.05, brightness = 0.9, popups = true },
  },
  animations = { enabled = true },
})

-- Motion. Speed is in 100 ms units. "liquid" overshoots a little (the island spring); "flow" settles fast.
-- Keyboard-mode rule kept: nothing slower than 300 ms, so it never feels mac-slow.
hl.curve("liquid", { type = "bezier", points = { { 0.32, 1.32 }, { 0.5, 1 } } })
hl.curve("flow", { type = "bezier", points = { { 0.2, 0.9 }, { 0.2, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
local MOTION = {
  { leaf = "global", speed = 2.5, bezier = "flow" },
  { leaf = "windows", speed = 2.6, bezier = "liquid" },
  { leaf = "windowsIn", speed = 2.6, bezier = "liquid", style = "popin 88%" },
  { leaf = "windowsOut", speed = 1.6, bezier = "flow", style = "popin 92%" },
  { leaf = "windowsMove", speed = 2.4, bezier = "liquid" },
  { leaf = "border", speed = 2, bezier = "flow" },
  { leaf = "borderangle", speed = 60, bezier = "linear", style = "loop" }, -- the slow turning gradient (6 s a lap)
  { leaf = "fade", speed = 2, bezier = "flow" },
  { leaf = "layers", speed = 2.4, bezier = "liquid" },
  { leaf = "layersIn", speed = 2.4, bezier = "liquid", style = "slide top" },
  { leaf = "layersOut", speed = 1.6, bezier = "flow", style = "fade" },
  { leaf = "workspaces", speed = 2.4, bezier = "flow", style = "slidefade 12%" },
}
for _, m in ipairs(MOTION) do
  m.enabled = true
  hl.animation(m)
end

return { LIQUID = LIQUID, MOTION = MOTION }
