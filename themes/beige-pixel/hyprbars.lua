-- Beige Pixel title bars (hyprbars), loaded by ~/.config/hypr/titlebars.lua instead of the traffic lights.
hl.config({
  plugin = {
    hyprbars = {
      bar_height = 24,
      bar_color = "rgba(fce4d3ff)",
      bar_title_enabled = true,
      ["col.text"] = "rgb(2e230a)",
      bar_text_font = "Monocraft",
      bar_text_size = 10,
      bar_text_align = "center",
      bar_buttons_alignment = "right",
      bar_padding = 12,
      bar_button_padding = 10,
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      icon_on_hover = false,
      inactive_button_color = "rgb(ca9a78)",
    },
  },
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(fce4d3)",
  fg_color = "rgb(665544)",
  size = 12,
  icon = "✕",
  action = [[hyprctl dispatch 'hl.dsp.window.close()']],
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(fce4d3)",
  fg_color = "rgb(665544)",
  size = 12,
  icon = "□",
  action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(fce4d3)",
  fg_color = "rgb(665544)",
  size = 12,
  icon = "—",
  action = [[hyprctl dispatch 'hl.dsp.window.move({ workspace = "empty", follow = false })']],
})
