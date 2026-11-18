local active_border_color = { colors = { "rgba(e0563bee)", "rgba(ff9a64ee)" }, angle = 45 }
local inactive_border_color = "rgba(2e231b99)"

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
