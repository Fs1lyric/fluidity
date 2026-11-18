return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#090e13", base01 = "#06090d", base02 = "#1d2128", base03 = "#393b44", base04 = "#717c7c", base05 = "#c5c9c7", base06 = "#c5c9c7", base07 = "#f2f1ef", base08 = "#e46876", base09 = "#dca561", base0A = "#e6c384", base0B = "#98bb6c", base0C = "#7aa89f", base0D = "#7fb4ca", base0E = "#938aa9", base0F = "#cba6f7" }) end,
    },
  },
}
