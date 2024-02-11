local M = {}


M.general = {
  n = {
    ["<C-h>"] = {"<cmd> TmuxNavigateLeft<CR>", "Tmux Navigate Left"},
    ["<C-j>"] = {"<cmd> TmuxNavigateDown<CR>", "Tmux Navigate Down"},
    ["<C-k>"] = {"<cmd> TmuxNavigateUp<CR>", "Tmux Navigate Up"},
    ["<C-l>"] = {"<cmd> TmuxNavigateRight<CR>", "Tmux Navigate Right"},
  }
}

M.copilot = {
  i = {
    ["<C-l>"] = {
      function ()
        vim.fn.feedkeys(vim.fn['copilot#Accept'](),'')
      end,
      "Copilot Accept",
      {replace_keycoders = true, nowait = true, silent = true, expr = true, noremap = true}
    }
  }
}

return M
