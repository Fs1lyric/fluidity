-- Frutiger Y2K feel, loaded after looknfeel.lua: its own gaps, border, corners and motion.
hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 14,
    border_size = 1,
  },
  decoration = {
    rounding = 14,
    active_opacity = 0.96,
    inactive_opacity = 0.9,
    shadow = { enabled = true, range = 24, render_power = 3, color = "rgba(6a8daeff)" },
  },
  -- Keyboard mode is snappy: short ease-out motion (~100-200 ms), no bouncy mac spring.
  animations = { enabled = true },
})

-- Overrides every leaf looknfeel.lua animates for mac mode. Speed is in 100 ms units.
hl.curve("snap", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "border", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "snap" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.8, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.2, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.8, bezier = "snap" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "snap", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.2, bezier = "snap" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.5, bezier = "snap", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "snap", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.5, bezier = "snap" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "snap" })

-- Dark glass: the bar is see-through and Hyprland blurs what is behind it.
hl.layer_rule({ match = { namespace = "qs-lum-.*" }, blur = true, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "qs-fy-.*" }, blur = true, ignore_alpha = 0.05 })

-- Keyboard-mode keys: Super+Ctrl+M goes back to mac mode.

-- Frutiger Y2K runs its own shell (qs -c frutiger-y2k) instead of the top bar.
o.bind("SUPER + GRAVE", "Sidebar", "qs -c frutiger-y2k ipc call sidebar toggle")
hl.unbind("SUPER + ESCAPE")
o.bind("SUPER + ESCAPE", "Exit screen", "qs -c frutiger-y2k ipc call exit toggle")
o.bind("SUPER + F1", "Dashboard", "qs -c frutiger-y2k ipc call dashboard toggle")

if io.open(keyboard, "r") then dofile(keyboard) end
