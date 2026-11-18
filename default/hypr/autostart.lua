-- Session services started with Hyprland: the Fluidity shell (island, bar, notifications, OSD), idle and lock,
-- the wallpaper, clipboard history. Your own extras go in ~/.config/hypr/autostart.lua.
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))
  hl.exec_cmd("fluidity-mode start")        -- the shell for the current mode (keyboard: qs -c fluidity; mac: the Tahoe set)
  hl.exec_cmd(o.launch("hypridle"))
  hl.exec_cmd("fluidity-wallpaper restore")
  hl.exec_cmd(o.launch("wl-paste --watch cliphist store"))
end)
