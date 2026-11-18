-- Nothing OS feel, loaded after looknfeel.lua: square windows, its own gaps, border and motion.
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
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

-- Nothing OS runs its author's shell (qs -c glyph, https://github.com/Nebelung-cloud/glyph-rice @0bab656) with its keys.
hl.unbind("SUPER + SUPER_L")
hl.bind("SUPER + SUPER_L", hl.dsp.global("shell:launcher"), { release = true })
hl.unbind("SUPER + I")
hl.bind("SUPER + I", hl.dsp.global("shell:settings"))
hl.unbind("SUPER + P")
hl.bind("SUPER + P", hl.dsp.global("shell:pact"))
hl.unbind("SUPER + SHIFT + W")
hl.bind("SUPER + SHIFT + W", hl.dsp.global("shell:wall"))
hl.unbind("SUPER + ESCAPE")
hl.bind("SUPER + ESCAPE", hl.dsp.global("shell:power"))
hl.unbind("SUPER + SHIFT + S")
hl.bind("SUPER + SHIFT + S", hl.dsp.global("shell:shot"))
hl.unbind("SUPER + Period")
hl.bind("SUPER + Period", hl.dsp.global("shell:charms"))
hl.unbind("SUPER + GRAVE")
hl.bind("SUPER + GRAVE", hl.dsp.global("shell:quick"))
hl.layer_rule({ match = { namespace = "glyph-power" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "glyph-(launcher|edge|island|buds|quick|home|bar|caffeine|shot|clip|charms|vpn|deck|prefs|hot|cal|wall|back)" }, no_anim = true })

if io.open(keyboard, "r") then dofile(keyboard) end
