return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#172a05", base01 = "#12210a", base02 = "#274604", base03 = "#467322", base04 = "#b6c99a", base05 = "#f0f7d8", base06 = "#f0f7d8", base07 = "#f0f7d8", base08 = "#e8385a", base09 = "#e5584c", base0A = "#e7f816", base0B = "#8fcf3c", base0C = "#7fd6b0", base0D = "#8fb0e0", base0E = "#e870a0", base0F = "#e7f816" }) end,
    },
  },
}
