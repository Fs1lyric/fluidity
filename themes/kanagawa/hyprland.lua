local active_border_color = { colors = { "rgba(7e9cd8ee)", "rgba(dca561ee)" }, angle = 45 }
local inactive_border_color = "rgba(2a2a3799)"

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
