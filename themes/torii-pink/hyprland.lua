local active_border_color = { colors = { "rgba(f6a0caee)", "rgba(f7b2d4ee)" }, angle = 45 }
local inactive_border_color = "rgba(28283999)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})
