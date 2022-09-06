local M = {}

function M.setup()
  require("utils.setup").run {
    autocmds = {
      {
        { "TermOpen" },
        {
          group = "__TERMINAL",
          pattern = "*",
          command = "nnoremap <buffer><LeftRelease> <LeftRelease>i",
        },
      },

      {
        { "BufWritePost" },
        {
          group = "__DEBUG_LAUNCHER",
          pattern = "launch.json",
          command = "lua require('dap.ext.vscode').load_launchjs()",
        },
      },

      -- __LAZYGIT = {
      --   OpenLgAfterGitCommit = {
      --     "BufWritePost",
      --     "COMMIT_EDITMSG",
      --     "lua require('lvim.core.terminal')._exec_toggle({ cmd = 'lazygit' })",
      --   },
      -- },
    },
  }
end

return M
