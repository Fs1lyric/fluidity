return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#292928", base01 = "#1f1f1e", base02 = "#3a3a38", base03 = "#585955", base04 = "#a3a5a7", base05 = "#d8d0b0", base06 = "#d8d0b0", base07 = "#d8d0b0", base08 = "#d0453a", base09 = "#d88a3a", base0A = "#d8b84a", base0B = "#80a040", base0C = "#5a9a98", base0D = "#7aa8c8", base0E = "#c87a9a", base0F = "#80c040" }) end,
    },
  },
}
