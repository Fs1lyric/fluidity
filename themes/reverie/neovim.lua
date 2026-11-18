return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#141118", base01 = "#100d13", base02 = "#27222f", base03 = "#3b3447", base04 = "#a095b2", base05 = "#f4f3f6", base06 = "#f4f3f6", base07 = "#ffffff", base08 = "#d66f6f", base09 = "#d5bc95", base0A = "#d6d36f", base0B = "#6fd692", base0C = "#6fd6d6", base0D = "#6f9ad6", base0E = "#9e70d7", base0F = "#9e70d7" }) end,
    },
  },
}
