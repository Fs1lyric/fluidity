return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#f2e6dc", base01 = "#ecdccf", base02 = "#faf3ee", base03 = "#b8a89c", base04 = "#6b5d55", base05 = "#1a1414", base06 = "#1a1414", base07 = "#1a1414", base08 = "#f28b82", base09 = "#f4a07a", base0A = "#f7d38a", base0B = "#b5e3a1", base0C = "#a8dcd9", base0D = "#a3c4f3", base0E = "#d8b4f8", base0F = "#f4a07a" }) end,
    },
  },
}
