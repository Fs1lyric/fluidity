local active_border_color = { colors = { "rgba(5ec8e1ee)", "rgba(033a91ee)" }, angle = 45 }
local inactive_border_color = "rgba(152a51ee)"

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
