return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#10011e", base01 = "#09011d", base02 = "#23014e", base03 = "#3f408b", base04 = "#6f32ba", base05 = "#9b9cc7", base06 = "#9b9cc7", base07 = "#cfd0ff", base08 = "#ff3b6b", base09 = "#c08cf0", base0A = "#f0e68c", base0B = "#4dff8a", base0C = "#00ffff", base0D = "#4b4dd2", base0E = "#a422c1", base0F = "#00ffff" }) end,
    },
  },
}
