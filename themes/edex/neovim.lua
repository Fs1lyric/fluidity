return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0c1114", base01 = "#090d10", base02 = "#1a2427", base03 = "#3a4c4e", base04 = "#779595", base05 = "#aacfd1", base06 = "#aacfd1", base07 = "#e4f4f5", base08 = "#c95f5f", base09 = "#d49a6a", base0A = "#d6c88a", base0B = "#7fbfa6", base0C = "#aacfd1", base0D = "#6fa3b0", base0E = "#9a93b8", base0F = "#aacfd1" }) end,
    },
  },
}
