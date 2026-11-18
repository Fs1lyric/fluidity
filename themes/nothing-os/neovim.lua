return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#000000", base01 = "#050505", base02 = "#141414", base03 = "#2a2a2a", base04 = "#8a8a8a", base05 = "#f2f2f2", base06 = "#f2f2f2", base07 = "#ffffff", base08 = "#d71921", base09 = "#e0533f", base0A = "#e8e8e8", base0B = "#bdbdbd", base0C = "#d0d0d0", base0D = "#a8a8a8", base0E = "#d71921", base0F = "#d71921" }) end,
    },
  },
}
