return {
  "folke/tokyonight.nvim",
  priority = 1000,
  opts = {
    transparent = not vim.g.neovide,
  },
  init = function()
    vim.cmd.colorscheme("tokyonight-night")
  end,
}
