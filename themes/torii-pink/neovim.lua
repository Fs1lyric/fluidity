return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#1c1e2a", base01 = "#16172a", base02 = "#282839", base03 = "#3a3a52", base04 = "#b9b9c9", base05 = "#ffffff", base06 = "#ffffff", base07 = "#ffffff", base08 = "#f38ba8", base09 = "#f5b38a", base0A = "#f5d58a", base0B = "#a6e3b0", base0C = "#8adce8", base0D = "#8ab4f8", base0E = "#f6a0ca", base0F = "#f6a0ca" }) end,
    },
  },
}
