return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#1a2026", base01 = "#161b20", base02 = "#242d35", base03 = "#526170", base04 = "#8796a3", base05 = "#ffffff", base06 = "#ffffff", base07 = "#f4f5f2", base08 = "#fb6396", base09 = "#f9a07e", base0A = "#f692b2", base0B = "#94cf95", base0C = "#7fe4d2", base0D = "#6ec1d6", base0E = "#cd84c8", base0F = "#6ec1d6" }) end,
    },
  },
}
