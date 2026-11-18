return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0c0201", base01 = "#080101", base02 = "#2a1110", base03 = "#552826", base04 = "#b98a87", base05 = "#f0dedf", base06 = "#f0dedf", base07 = "#f0dedf", base08 = "#c4102d", base09 = "#e8835e", base0A = "#f2c38a", base0B = "#a8c79a", base0C = "#9fc9c4", base0D = "#8fa8d8", base0E = "#e09ab0", base0F = "#ffbebc" }) end,
    },
  },
}
