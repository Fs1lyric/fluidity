-- Glass for the shell's layers. ignore_alpha keeps the blur to the drawn shapes: the island's glass and the
-- cards are blurred, the clear parts of a full-screen layer (and the overlay's light dim) are not.
local glass = { blur = true, ignore_alpha = 0.3 }
for _, ns in ipairs({ "fluidity-bar", "fluidity-island", "fluidity-desktop", "fluidity-themes" }) do
  hl.layer_rule({ match = { namespace = ns }, blur = glass.blur, ignore_alpha = glass.ignore_alpha })
end
-- mac mode (tahoe-bar, dock)
hl.layer_rule({ match = { namespace = "qs-dock" }, blur = true, blur_popups = true, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "qs-menubar" }, blur_popups = true, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "qs-menu" }, blur = true, ignore_alpha = 0.05 })
hl.layer_rule({ match = { namespace = "qs-dock-genie" }, no_anim = true })
hl.layer_rule({ match = { namespace = "qs-lyric-.*" }, blur = true, ignore_alpha = 0.05 })
