if vim.g.nvim_theme == "catppuccin" then
  return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = vim.g.catppuccin_flavor or "mocha",
      term_colors = true,
      transparent_background = not vim.g.neovide,
    },
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  }
end

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
