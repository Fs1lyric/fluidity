local active_border_color = { colors = { "rgba(c574ddee)", "rgba(8897f4ee)" }, angle = 45 }
local inactive_border_color = "rgba(282a3699)"

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
