return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#f1ead8", base01 = "#e8e0cb", base02 = "#e2dccb", base03 = "#a2a39a", base04 = "#5a5c59", base05 = "#262626", base06 = "#262626", base07 = "#262626", base08 = "#c8553d", base09 = "#d98a4a", base0A = "#b8902a", base0B = "#5f8f4e", base0C = "#3f8f8a", base0D = "#3d6f9e", base0E = "#9a5a8a", base0F = "#4f9e98" }) end,
    },
  },
}
