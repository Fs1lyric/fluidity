-- System Settings (fluidity-settings, qs -c settings): a fixed-size floating window that draws its own
-- traffic lights and Tahoe corners, so no hyprbars title bar and no default translucency.
o.window("lyric.settings", { float = true, center = true, size = { 894, 775 }, rounding = 20 })  -- Tahoe is 26; Hyprland caps it at 20
o.window("lyric.settings", { ["hyprbars:no_bar"] = true })
o.window("lyric.settings", { tag = "-default-opacity" })
o.window("lyric.settings", { opacity = "1 1" })
