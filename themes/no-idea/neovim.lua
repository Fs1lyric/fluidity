return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#121212", base01 = "#0e0e0e", base02 = "#272626", base03 = "#4e4e4e", base04 = "#a5b3c0", base05 = "#ffd5cd", base06 = "#ffd5cd", base07 = "#ffffff", base08 = "#d35d6e", base09 = "#f0ac7b", base0A = "#ffcb6b", base0B = "#90c861", base0C = "#89ddff", base0D = "#84afdb", base0E = "#c47eb7", base0F = "#d35d6e" }) end,
    },
  },
}
