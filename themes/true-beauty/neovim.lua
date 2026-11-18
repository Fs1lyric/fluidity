return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0a0614", base01 = "#070410", base02 = "#18192b", base03 = "#3a2f6b", base04 = "#c8b8ff", base05 = "#ffffff", base06 = "#ffffff", base07 = "#ffffff", base08 = "#ff3b3b", base09 = "#ff9a1f", base0A = "#ffff00", base0B = "#39ff14", base0C = "#16ffff", base0D = "#3b5bff", base0E = "#ff10ff", base0F = "#16ffff" }) end,
    },
  },
}
