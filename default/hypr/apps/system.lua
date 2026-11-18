-- Floating windows.
o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })

o.window(
  "(fluidity.btop|fluidity.terminal|fluidity.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|About|TUI.float|imv|mpv)",
  {
    tag = "+floating-window",
  }
)

-- The portal only ever shows dialogs — file pickers, screen shares, permission
-- prompts — so every one of its windows belongs in the floating treatment,
-- whatever the app that asked for it titled it.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window({
  class = "(sublime_text|DesktopEditors|org.gnome.Nautilus)",
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
}, { tag = "+floating-window" })


o.window("dev.tensaku.Tensaku", { float = true })
o.window("dev.tensaku.Tensaku", { center = true })
o.window("omacalc", { float = true })


-- No transparency on media windows, games and game streaming.
local solid = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer"
  .. "|io.github.celluloid_player.Celluloid|org.kde.haruna|org.gnome.Totem|com.stremio.stremio|FreeTube"
  .. "|steam_app_.*|gamescope|[Mm]inecraft.*|com.moonlight_stream.Moonlight|GeForceNOW)$"
o.window(solid, {
  tag = "-default-opacity",
})
o.window(
  solid,
  {
    opacity = "1 1",
  }
)

-- Popped window rounding.
o.window({ tag = "pop" }, { rounding = 0 })

-- Prevent idle while open.
o.window({ tag = "noidle" }, { idle_inhibit = "always" })
