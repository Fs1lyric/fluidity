return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#1d2021", base01 = "#161819", base02 = "#282828", base03 = "#3f3f3f", base04 = "#928374", base05 = "#d4be98", base06 = "#d4be98", base07 = "#d4be98", base08 = "#ea6962", base09 = "#e78a4e", base0A = "#d8a657", base0B = "#a9b665", base0C = "#89b482", base0D = "#7daea3", base0E = "#d3869b", base0F = "#89b482" }) end,
    },
  },
}
