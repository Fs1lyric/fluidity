return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#1d1f28", base01 = "#191a22", base02 = "#282a36", base03 = "#414458", base04 = "#8a8ca5", base05 = "#fdfdfd", base06 = "#fdfdfd", base07 = "#bebec1", base08 = "#f37f97", base09 = "#f2a272", base0A = "#f2a272", base0B = "#5adecd", base0C = "#79e6f3", base0D = "#8897f4", base0E = "#c574dd", base0F = "#c574dd" }) end,
    },
  },
}
