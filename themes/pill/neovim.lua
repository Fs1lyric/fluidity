return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#211711", base01 = "#1b130e", base02 = "#2e231b", base03 = "#3a2a22", base04 = "#8a7d74", base05 = "#e6d6cb", base06 = "#e6d6cb", base07 = "#fff6f0", base08 = "#e0533f", base09 = "#ff9a64", base0A = "#e6c38a", base0B = "#a9b98a", base0C = "#9cc3b8", base0D = "#9aa9c9", base0E = "#c98aa0", base0F = "#e0563b" }) end,
    },
  },
}
