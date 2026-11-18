return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#fce4d3", base01 = "#f4d6c0", base02 = "#e6c7b0", base03 = "#ca9a78", base04 = "#917156", base05 = "#2e230a", base06 = "#2e230a", base07 = "#2e230a", base08 = "#b2442a", base09 = "#c8702e", base0A = "#a8862a", base0B = "#5f7a2e", base0C = "#3f7a7a", base0D = "#48899f", base0E = "#8a4a6a", base0F = "#9e4f2b" }) end,
    },
  },
}
