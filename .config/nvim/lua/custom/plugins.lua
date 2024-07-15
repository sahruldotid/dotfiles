local plugins = {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "gopls",
        "pyright",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function ()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "github/copilot.vim",
    lazy = false,
    config = function ()
      vim.g.copilot_no_tab_map = true;
      vim.g.copilot_assume_mapped = true;
      vim.g.copilot_tab_fallback = "";
    end,
  },
  {
   "typicode/bg.nvim",
    lazy = false,
  },
  {
    "andweeb/presence.nvim",
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "numToStr/Comment.nvim",
    opts = {
    }
  }
}

return plugins
