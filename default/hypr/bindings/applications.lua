o.bind("SUPER + RETURN", "Terminal", { app = "terminal" })
o.bind("SUPER + ALT + RETURN", "Tmux", { app = "tmux" })
o.bind("SUPER + SHIFT + RETURN", "Browser", { app = "browser" })
o.bind("SUPER + SHIFT + B", "Browser", { app = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { app = "browser --private" })
o.bind("SUPER + SHIFT + F", "File manager", { app = "files" })
o.bind("SUPER + F", "Screen Time", "fluidity-wellbeing app")   -- full screen moved to Super+R
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { app = "files --cwd" })
o.bind("SUPER + SHIFT + N", "Editor", { app = "editor" })
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

-- Upstream's Super+Shift app slots, pointed at your apps. Always bound: fluidity-launch says so if one is missing.
local apps = {
  { "SUPER + CTRL + RETURN", "Herdr", "herdr", { tui = "herdr" } },
  { "SUPER + SHIFT + M", "Music", "spotify", { launch = "spotify", focus = "spotify" } },
  { "SUPER + SHIFT + ALT + M", "Music TUI", "cliamp", { tui = "cliamp", focus = true } },
  { "SUPER + SHIFT + D", "Docker", "lazydocker", { tui = "lazydocker" } },
  { "SUPER + SHIFT + O", "Obsidian", "obsidian", { launch = "obsidian", focus = "^obsidian$" } },
  { "SUPER + SHIFT + W", "Writer (Margin)", "margin", { launch = "margin" } },
}
for _, a in ipairs(apps) do
  o.bind(a[1], a[2], a[4])
end

o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
o.bind("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
o.bind("SUPER + SHIFT + C", "Calendar (Calendio)", { launch = "calendio", focus = "calendio" })
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
o.bind("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
o.bind("SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
o.bind("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
o.bind("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
o.bind("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
o.bind("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })
