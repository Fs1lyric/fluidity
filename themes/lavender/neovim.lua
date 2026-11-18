return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#c6c1f4", base01 = "#b8b2ec", base02 = "#9988cb", base03 = "#85799e", base04 = "#63617a", base05 = "#2b2735", base06 = "#2b2735", base07 = "#ffffff", base08 = "#c75f7f", base09 = "#d58a6a", base0A = "#c9a95a", base0B = "#6f9a7b", base0C = "#5f9aa8", base0D = "#6f78c8", base0E = "#a06fb5", base0F = "#9988cb" }) end,
    },
  },
}
