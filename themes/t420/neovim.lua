return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#140c0d", base01 = "#100a0b", base02 = "#2a1e20", base03 = "#4a3a3c", base04 = "#9a8a8a", base05 = "#d8cfc8", base06 = "#d8cfc8", base07 = "#d8cfc8", base08 = "#c77778", base09 = "#a8682e", base0A = "#c9a86a", base0B = "#7fc98f", base0C = "#477777", base0D = "#597b99", base0E = "#9a6a8a", base0F = "#7fc98f" }) end,
    },
  },
}
