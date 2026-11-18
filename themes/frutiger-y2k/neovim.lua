return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#f4f6f8", base01 = "#e1e4e7", base02 = "#e8edf2", base03 = "#a2a8ae", base04 = "#6a7a8a", base05 = "#2d333e", base06 = "#2d333e", base07 = "#2d333e", base08 = "#d8404a", base09 = "#e0803a", base0A = "#c9a227", base0B = "#3a9a5a", base0C = "#2a9ab8", base0D = "#1e6ed0", base0E = "#8a5ad0", base0F = "#1e6ed0" }) end,
    },
  },
}
