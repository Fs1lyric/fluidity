local active_border_color = { colors = { "rgba(ff16b0ee)", "rgba(46bdffee)" }, angle = 45 }
local inactive_border_color = "rgba(202a4cee)"

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
