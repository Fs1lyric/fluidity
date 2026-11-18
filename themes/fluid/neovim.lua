return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function() require("base16-colorscheme").setup({ base00 = "#111417", base01 = "#0c0e10", base02 = "#1b1f23", base03 = "#3a3f45", base04 = "#878880", base05 = "#e3e4da", base06 = "#e3e4da", base07 = "#e3e4da", base08 = "#f2a7a7", base09 = "#f0c08a", base0A = "#e8d98a", base0B = "#cfe3a8", base0C = "#c2e6d6", base0D = "#a9b8e8", base0E = "#c8a8e0", base0F = "#d7e59b" }) end,
    },
  },
}
