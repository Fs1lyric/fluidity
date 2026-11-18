-- Capture, sharing, dictation and hardware keys: every upstream chord, Fluidity commands behind them.
-- Upstream's menus (capture, toggle, hardware, share) open the matching leader row instead; menus are gone.
o.bind("PRINT", "Screenshot", "fluidity-capture screenshot")
o.bind("ALT + PRINT", "Screen recording", "fluidity-capture record")
o.bind("SUPER + PRINT", "Colour picker", "fluidity-capture colour")
o.bind("SUPER + CTRL + PRINT", "Copy text from the screen (OCR)", "fluidity-capture ocr")
o.bind("SUPER + CTRL + C", "Capture keys", "fluidity-leader capture")
o.bind("SUPER + CTRL + O", "Toggle keys", "fluidity-leader toggle")
o.bind("SUPER + CTRL + H", "Hardware keys", "fluidity-leader hardware")
o.bind("SUPER + CTRL + S", "Share", "fluidity-leader share")
o.bind("SUPER + CTRL + PERIOD", "Transcode", "fluidity-transcode")
o.bind("SUPER + CTRL + ALT + B", "Battery remaining", "fluidity-util battery")

-- Dictation (voxtype). Bound always; fluidity-dictate says so if voxtype is missing.
o.bind("SUPER + CTRL + X", "Toggle dictation", "fluidity-dictate toggle")
o.bind("F9", "Start dictation (push-to-talk)", "fluidity-dictate start")
o.bind("F9", "Stop dictation (push-to-talk)", "fluidity-dictate stop", { release = true })

-- Scratch terminal: a floating terminal on the workspace you are on (never a hidden special workspace).
o.bind("SUPER + S", "Scratch terminal", "fluidity-scratch toggle")
o.bind("SUPER + ALT + S", "Make this the scratch window", "fluidity-scratch take")

o.bind("SUPER + SHIFT + SPACE", "Toggle the bar", "fluidity-island bar")
o.bind("SUPER + SHIFT + G", "Signal", { launch = "signal-desktop", focus = "^signal$" })
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "1password" })

-- Displays, keyboard light, touchpad, audio output.
o.bind("SUPER + CTRL + DELETE", "Toggle laptop display", "fluidity-display internal toggle")
o.bind("SUPER + CTRL + ALT + DELETE", "Toggle display mirroring", "fluidity-display mirror")
o.bind("switch:on:Lid Switch", "Lid closed", "fluidity-display lid closed", { locked = true })
o.bind("switch:off:Lid Switch", "Lid opened", "fluidity-display lid open", { locked = true })
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "fluidity-hw kbd up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "fluidity-hw kbd down", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "fluidity-hw kbd cycle", { locked = true })
o.bind("XF86TouchpadToggle", "Toggle touchpad", "fluidity-hw touchpad toggle", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "fluidity-hw touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "fluidity-hw touchpad off", { locked = true })
o.bind("SUPER + XF86AudioMute", "Switch audio output", "fluidity-audio next-output", { locked = true })
