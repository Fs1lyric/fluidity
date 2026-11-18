-- Burrow (Finder copy, ~/claude/burrow): opens floating and centred at a medium size, like Finder on a Mac:
-- Finder's 920x540 default x BURROW_SCALE 1.25 (set in ~/.local/bin/burrow-launch). It draws its own
-- traffic lights and keeps the default glass translucency.
-- [Bb]: under XWayland (QT_QPA_PLATFORM falls back to xcb) the class is "Burrow", which ^burrow$ missed and the window tiled.
o.window("^[Bb]urrow$", { float = true, center = true, size = { 1150, 675 } })
o.window("^[Bb]urrow$", { ["hyprbars:no_bar"] = true })
-- No whole-window fade: Burrow draws its own glass behind the sidebar and keeps the files solid,
-- as in Tahoe's Finder (the compositor still blurs the wallpaper through the see-through parts).
o.window("^[Bb]urrow$", { tag = "-default-opacity" })
o.window("^[Bb]urrow$", { opacity = "1 1" })
