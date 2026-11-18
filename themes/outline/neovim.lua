return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0f1012", base01 = "#0b0c0e", base02 = "#1d1f23", base03 = "#3a3d44", base04 = "#9a9ea8", base05 = "#e6e6e6", base06 = "#e6e6e6", base07 = "#e6e6e6", base08 = "#e06c75", base09 = "#e5a06a", base0A = "#e0c080", base0B = "#98c379", base0C = "#7fc8c8", base0D = "#7aa2d8", base0E = "#c39ad8", base0F = "#e0c080" }) end,
    },
  },
}
