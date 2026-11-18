-- Persona feel, loaded after looknfeel.lua: its own gaps, border, corners and motion.
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 14,
    border_size = 2,
  },
  decoration = {
    rounding = 6,
    shadow = { enabled = false },
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

-- Keyboard-mode keys: Super+Ctrl+M goes back to mac mode.

-- Persona runs its own shell (qs -c persona) instead of the top bar.
o.bind("SUPER + GRAVE", "Sidebar", "qs -c persona ipc call sidebar toggle")
hl.unbind("SUPER + ESCAPE")
o.bind("SUPER + ESCAPE", "Exit screen", "qs -c persona ipc call exit toggle")
o.bind("SUPER + F1", "Dashboard", "qs -c persona ipc call dashboard toggle")

