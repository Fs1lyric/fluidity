return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#fdf6e3", base01 = "#f4eedc", base02 = "#e6e2cc", base03 = "#a6b0a0", base04 = "#5c6a72", base05 = "#000000", base06 = "#000000", base07 = "#a6b0a0", base08 = "#f85552", base09 = "#f57d26", base0A = "#dfa000", base0B = "#8da101", base0C = "#35a77c", base0D = "#3a94c5", base0E = "#df69ba", base0F = "#000000" }) end,
    },
  },
}
