return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#1d0b12", base01 = "#160810", base02 = "#32141f", base03 = "#4d1927", base04 = "#685841", base05 = "#bfb098", base06 = "#bfb098", base07 = "#e8dcc8", base08 = "#fc2e64", base09 = "#c9764a", base0A = "#bfb098", base0B = "#8f9a5c", base0C = "#7a9a92", base0D = "#7a7fa8", base0E = "#c0507a", base0F = "#fc2e64" }) end,
    },
  },
}
