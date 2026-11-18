return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#141830", base01 = "#0f1226", base02 = "#202a4c", base03 = "#2d496f", base04 = "#8fa8c8", base05 = "#e6e6f0", base06 = "#e6e6f0", base07 = "#ffffff", base08 = "#ff2a6d", base09 = "#ff8c42", base0A = "#f9f871", base0B = "#b6f23a", base0C = "#2de2e6", base0D = "#46bdff", base0E = "#ff16b0", base0F = "#ff16b0" }) end,
    },
  },
}
