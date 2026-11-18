return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#0c0f1d", base01 = "#090b16", base02 = "#152a51", base03 = "#394560", base04 = "#7f9ab8", base05 = "#e2f1f9", base06 = "#e2f1f9", base07 = "#e2f1f9", base08 = "#e0566a", base09 = "#f0a050", base0A = "#fffb9f", base0B = "#5ee8a0", base0C = "#1cc9d9", base0D = "#1788b6", base0E = "#9a8cf0", base0F = "#17a9d5" }) end,
    },
  },
}
