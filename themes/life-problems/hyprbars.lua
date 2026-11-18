-- Life Problems title bars (hyprbars), loaded by ~/.config/hypr/titlebars.lua instead of the traffic lights.
hl.config({
  plugin = {
    hyprbars = {
      bar_height = 34,
      bar_color = "rgba(f1ead8ff)",
      bar_title_enabled = true,
      ["col.text"] = "rgb(262626)",
      bar_text_font = "Roboto Mono Medium",
      bar_text_size = 11,
      bar_text_align = "center",
      bar_buttons_alignment = "left",
      bar_padding = 12,
      bar_button_padding = 10,
      bar_part_of_window = true,
      bar_precedence_over_border = true,
      icon_on_hover = false,
      inactive_button_color = "rgb(a2a39a)",
    },
  },
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(f1ead8)",
  fg_color = "rgb(262626)",
  size = 16,
  icon = "◯",
  action = [[hyprctl dispatch 'hl.dsp.window.close()']],
})
hl.plugin.hyprbars.add_button({
  bg_color = "rgb(f1ead8)",
  fg_color = "rgb(262626)",
  size = 16,
  icon = "◯",
  action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
})
