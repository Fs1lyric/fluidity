-- Perfect World title bars (hyprbars), loaded by ~/.config/hypr/titlebars.lua instead of the traffic lights.
hl.config({
  plugin = {
    hyprbars = {
      bar_height = 35,
      bar_color = "rgba(1a2026ff)",
      bar_title_enabled = false,
      bar_buttons_alignment = "right",
      bar_padding = 12,
      bar_button_padding = 10,
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      icon_on_hover = false,
      inactive_button_color = "rgb(526170)",
    },
  },
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(1a2026)",
  fg_color = "rgb(fb6396)",
  size = 10,
  icon = "♥",
  action = [[hyprctl dispatch 'hl.dsp.window.close()']],
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(1a2026)",
  fg_color = "rgb(94cf95)",
  size = 10,
  icon = "●",
  action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(1a2026)",
  fg_color = "rgb(f692b2)",
  size = 10,
  icon = "●",
  action = [[hyprctl dispatch 'hl.dsp.window.move({ workspace = "empty", follow = false })']],
})
