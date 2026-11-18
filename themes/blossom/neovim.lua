return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#272e33", base01 = "#1e2326", base02 = "#374145", base03 = "#4f585e", base04 = "#859289", base05 = "#d3c6aa", base06 = "#d3c6aa", base07 = "#d3c6aa", base08 = "#e67e80", base09 = "#e69875", base0A = "#dbbc7f", base0B = "#a7c080", base0C = "#83c092", base0D = "#7fbbb3", base0E = "#d699b6", base0F = "#83c092" }) end,
    },
  },
}
