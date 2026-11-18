-- Toolkit daemon windows (qs -c toolkit, QS_APP_ID=lyric.toolkit): they draw their own chrome, so no hyprbars bar.
-- Linked into ~/.config/hypr/lyric/apps/ by ~/claude/archy-cleanup/toolkit/install.sh.
local tk = "lyric.toolkit"
o.window({ class = tk }, { float = true, ["hyprbars:no_bar"] = true, tag = "-default-opacity", opacity = "1 1" })
o.window({ class = tk, title = "Screenshot" }, { center = true, size = { 1375, 900 }, rounding = 14 })
o.window({ class = tk, title = "Scratchpad" }, { size = { 525, 650 }, move = { "100%-440", 60 }, pin = true, rounding = 14 })
o.window({ class = tk, title = "Camera Preview" }, { size = { 600, 450 }, move = { "100%-500", 60 }, pin = true, rounding = 14 })
