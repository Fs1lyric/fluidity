return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#fbf1c7", base01 = "#f2e5bc", base02 = "#ebdbb2", base03 = "#d5c4a1", base04 = "#7c6f64", base05 = "#3c3836", base06 = "#3c3836", base07 = "#282828", base08 = "#9d0006", base09 = "#af3a03", base0A = "#b57614", base0B = "#79740e", base0C = "#427b58", base0D = "#076678", base0E = "#8f3f71", base0F = "#79740e" }) end,
    },
  },
}
