-- Volume goes through PipeWire and brightness over DDC (fluidity-shell); the Quickshell
-- Volume and brightness keys. The island shows the OSD (qs -c fluidity watches PipeWire).
local sink = "@DEFAULT_AUDIO_SINK@"
local volume = function(step)
  return "wpctl set-mute " .. sink .. " 0 && wpctl set-volume -l 2.0 " .. sink .. " " .. step
end
local brightness = function(value)
  return "fluidity-shell brightness " .. value
end
local locked_repeat = { locked = true, repeating = true }

o.bind("XF86AudioRaiseVolume", "Volume up", volume("5%+"), locked_repeat)
o.bind("XF86AudioLowerVolume", "Volume down", volume("5%-"), locked_repeat)
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", volume("1%+"), locked_repeat)
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", volume("1%-"), locked_repeat)
o.bind("XF86AudioMute", "Mute", "wpctl set-mute " .. sink .. " toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
o.bind("SHIFT + XF86AudioMute", "Switch audio output", "fluidity-audio next-output", { locked = true })

o.bind("XF86MonBrightnessUp", "Brightness up", brightness("up 5"), locked_repeat)
o.bind("XF86MonBrightnessDown", "Brightness down", brightness("down 5"), locked_repeat)
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", brightness("up 1"), locked_repeat)
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", brightness("down 1"), locked_repeat)
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", brightness("set 100"), { locked = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", brightness("set 1"), { locked = true })

local mpris = {
  { "XF86AudioNext", "Next track", "next" },
  { "ALT + XF86AudioPlay", "Next track", "next" },
  { "XF86AudioPause", "Pause", "toggle" },
  { "XF86AudioPlay", "Play", "toggle" },
  { "XF86AudioPrev", "Previous track", "previous" },
  { "ALT + SHIFT + XF86AudioPlay", "Previous track", "previous" },
}
for _, b in ipairs(mpris) do
  o.bind(b[1], b[2], "fluidity-media " .. b[3], { locked = true })
end
o.bind("XF86Eject", "Eject media", "eject", { locked = true })
