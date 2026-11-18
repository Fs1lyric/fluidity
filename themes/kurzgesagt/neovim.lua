return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#e8f6f0", base01 = "#d8eee6", base02 = "#cfe9e1", base03 = "#8fbcb4", base04 = "#3f7470", base05 = "#16324a", base06 = "#16324a", base07 = "#16324a", base08 = "#d0495a", base09 = "#e07a42", base0A = "#ac9a3e", base0B = "#15a86a", base0C = "#11948a", base0D = "#2a7ad0", base0E = "#5a68e2", base0F = "#c06a52" }) end,
    },
  },
}
