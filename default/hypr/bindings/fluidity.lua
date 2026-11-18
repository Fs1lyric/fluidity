-- Fluidity's own layer: one chord per app (open-or-focus, never a second copy, never hidden),
-- the leader, click hints and the cheat sheet. Only keys upstream leaves free (see PLAN.md "Keymap").
local function app(key, name, class, command)
  o.bind("SUPER + " .. key, name, "fluidity-launch focus " .. o.shell_quote(class) .. " " .. o.launch(command))
end

app("A", "Calendio", "calendio", "calendio")
app("B", "Zen", "zen", "zen-browser")
app("D", "Vesktop", "vesktop", "vesktop")
app("M", "Spotify", "spotify", "spotify")
app("N", "Obsidian", "obsidian", "obsidian")
app("E", "Burrow (files)", "burrow", "burrow")
app("I", "Claude", "claude", "claude-desktop")
app("U", "Flowday", "flowday", "flowday")
app("Z", "VS Code Insiders", "code-insiders", "code-insiders")
o.bind("SUPER + H", "btop", "fluidity-launch focus-tui btop")

-- Zen lives on workspace 2.
o.window({ class = "^zen$" }, { workspace = "2" })

o.bind("SUPER + Q", "Click hints", "fluidity-hints")
o.bind("SUPER + SEMICOLON", "Leader", "fluidity-leader")
o.bind("SUPER + K", "Cheat sheet", "fluidity-island cheatsheet")
o.bind("SUPER + PERIOD", "Emoji", "fluidity-island emoji")
