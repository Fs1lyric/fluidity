return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0a0a0a", base01 = "#050505", base02 = "#1c1c1c", base03 = "#3a3a3a", base04 = "#9a9a9a", base05 = "#e8e8e8", base06 = "#e8e8e8", base07 = "#ffffff", base08 = "#d6d6d6", base09 = "#c8c8c8", base0A = "#f0f0f0", base0B = "#b4b4b4", base0C = "#dcdcdc", base0D = "#a7a7a7", base0E = "#cfcfcf", base0F = "#ffffff" }) end,
    },
  },
}
