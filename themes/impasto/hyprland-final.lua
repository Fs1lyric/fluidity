-- Impasto feel, loaded after looknfeel.lua: square windows, its own gaps, border and motion.
hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 16,
    border_size = 1,
  },
  decoration = {
    rounding = 0,
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

-- Impasto runs its author's shell (qs -c impasto, https://github.com/andreumassanet/impasto @311b808) with its keys.
hl.unbind("SUPER + SPACE")
hl.bind("SUPER + SPACE", hl.dsp.global("quickshell:launcher"))
hl.bind("SUPER + F1", hl.dsp.global("quickshell:session"))
hl.unbind("SUPER + ESCAPE")
hl.bind("SUPER + ESCAPE", hl.dsp.global("quickshell:session"))
hl.bind("SUPER + F2", hl.dsp.global("quickshell:overview"))
hl.bind("SUPER + F3", hl.dsp.global("quickshell:settings"))
hl.bind("SUPER + F4", hl.dsp.global("quickshell:appearance"))
hl.bind("SUPER + F5", hl.dsp.global("quickshell:stats"))
hl.bind("SUPER + F6", hl.dsp.global("quickshell:zen"))
hl.bind("SUPER + F7", hl.dsp.global("quickshell:widgets"))
hl.unbind("SUPER + GRAVE")
hl.bind("SUPER + GRAVE", hl.dsp.global("quickshell:controls"))

if io.open(keyboard, "r") then dofile(keyboard) end

-- Fluidity moved these off its own keys (tools/free-theme-keys.py): SUPER + X -> SUPER + F1, SUPER + TAB -> SUPER + F2, SUPER + comma -> SUPER + F3, SUPER + T -> SUPER + F4, SUPER + U -> SUPER + F5, SUPER + CTRL + B -> SUPER + F6, SUPER + CTRL + W -> SUPER + F7
