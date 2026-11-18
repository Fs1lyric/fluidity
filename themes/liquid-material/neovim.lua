return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#141016", base01 = "#0f0c11", base02 = "#2a2230", base03 = "#493557", base04 = "#a998b4", base05 = "#ece0f2", base06 = "#ece0f2", base07 = "#ece0f2", base08 = "#ff8a6a", base09 = "#e8743c", base0A = "#f0c48a", base0B = "#b6d7a8", base0C = "#a8d4e0", base0D = "#b0b8f0", base0E = "#d6a0e8", base0F = "#e3b5f5" }) end,
    },
  },
}
