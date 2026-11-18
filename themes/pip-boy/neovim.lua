return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0a1a0c", base01 = "#08140a", base02 = "#14301a", base03 = "#2a552e", base04 = "#49a260", base05 = "#8ff0b8", base06 = "#8ff0b8", base07 = "#c8fbe0", base08 = "#b6f5a0", base09 = "#9ee890", base0A = "#d0f7b0", base0B = "#60e597", base0C = "#9cf7d0", base0D = "#51c673", base0E = "#7ed8a8", base0F = "#60e597" }) end,
    },
  },
}
