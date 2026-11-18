return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#f4f8fa", base01 = "#e9eef3", base02 = "#c9dfe6", base03 = "#9eb8c8", base04 = "#55788d", base05 = "#12404a", base06 = "#12404a", base07 = "#12404a", base08 = "#d9566e", base09 = "#e08a4a", base0A = "#c9a227", base0B = "#5c9a1a", base0C = "#2b8fa6", base0D = "#4a78c8", base0E = "#8a6ad8", base0F = "#3f9fb8" }) end,
    },
  },
}
