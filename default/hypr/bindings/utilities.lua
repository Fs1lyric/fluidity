-- Shell surfaces. Every popup is the island (qs -c fluidity), opened through fluidity-island <view>.
local island = function(view) return "fluidity-island " .. view end

o.bind("SUPER + SPACE", "Launcher", island("launcher"))
o.bind("SUPER + ALT + SPACE", "Launcher", island("launcher"))
o.bind("SUPER + SHIFT + code:201", "Launcher", island("launcher"))
o.bind("SUPER + ESCAPE", "Power", island("power"))
o.bind("XF86PowerOff", "Power", island("power"), { locked = true })
o.bind("SUPER + CTRL + SPACE", "Wallpaper", island("wallpaper"))
o.bind("SUPER + SHIFT + CTRL + SPACE", "Theme picker", island("themes"))
o.bind("SUPER + ALT + K", "Tmux keybindings", island("cheatsheet tmux"))
o.bind("SUPER + CTRL + E", "Emoji", island("emoji"))
o.bind("SUPER + CTRL + Q", "Calculator", island("launcher ="))
o.bind("XF86Calculator", "Calculator", island("launcher ="))

-- Control centre and notifications.
o.bind("SUPER + CTRL + A", "Control centre", island("control"))
o.bind("SUPER + CTRL + B", "Control centre", island("control"))
o.bind("SUPER + CTRL + W", "Control centre", island("control"))
o.bind("SUPER + CTRL + ALT + D", "Control centre", island("control"))
o.bind("SUPER + CTRL + P", "Power", island("power"))
o.bind("SUPER + comma", "Dismiss notification", "fluidity-notify dismiss")
o.bind("SUPER + SHIFT + comma", "Clear notifications", "fluidity-notify clear")
o.bind("SUPER + ALT + comma", "Notification history", island("notifications"))
o.bind("SUPER + SHIFT + ALT + comma", "Notification history", island("notifications"))
o.bind("SUPER + CTRL + comma", "Do not disturb", "fluidity-notify dnd")

-- Window look toggles.
o.bind("SUPER + BACKSPACE", "Toggle window transparency", "fluidity-window transparency")
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", "fluidity-window gaps")
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", "fluidity-window aspect")
o.bind("SUPER + CTRL + I", "Toggle idle lock", "fluidity-toggle idle")
o.bind("SUPER + CTRL + N", "Toggle night light", "fluidity-toggle nightlight")

-- Reminders and quick info.
o.bind("SUPER + CTRL + R", "Set reminder", "fluidity-util remind")
o.bind("SUPER + CTRL + ALT + R", "Show reminders", "fluidity-util reminders")
o.bind("SUPER + SHIFT + CTRL + R", "Clear reminders", "fluidity-util clear-reminders")
o.bind("SUPER + CTRL + ALT + T", "Show time", "fluidity-util time")
o.bind("SUPER + CTRL + ALT + W", "Show weather", "fluidity-util weather")

-- Cursor zoom.
o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)
o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

o.bind("SUPER + CTRL + L", "Lock", "fluidity-lock")
