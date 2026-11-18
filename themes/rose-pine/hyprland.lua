local active_border_color = { colors = { "rgba(c4a7e7ee)", "rgba(ebbcbaee)" }, angle = 45 }
local inactive_border_color = "rgba(26233a99)"

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
