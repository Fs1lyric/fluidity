return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0c0c0c", base01 = "#080808", base02 = "#141414", base03 = "#282828", base04 = "#8e8e93", base05 = "#ffffff", base06 = "#ffffff", base07 = "#ffffff", base08 = "#ff453a", base09 = "#ff9f0a", base0A = "#ffd60a", base0B = "#30d158", base0C = "#64d2ff", base0D = "#0a84ff", base0E = "#bf5af2", base0F = "#0a84ff" }) end,
    },
  },
}
