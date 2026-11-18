return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0b2a4a", base01 = "#082440", base02 = "#1d4a78", base03 = "#3b6a9a", base04 = "#a9c4e0", base05 = "#f2f7fc", base06 = "#f2f7fc", base07 = "#f2f7fc", base08 = "#f5768c", base09 = "#ffa79b", base0A = "#ffea8e", base0B = "#8fe0b0", base0C = "#7fd6f0", base0D = "#4fa3e8", base0E = "#9099f9", base0F = "#ffffff" }) end,
    },
  },
}
