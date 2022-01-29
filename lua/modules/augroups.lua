local M = {}

M.setup = function()
  require("lvim.core.autocmds").define_augroups {
    __TERMINAL = {
      TerminalOpen = { "TermOpen", "*", "nnoremap <buffer><LeftRelease> <LeftRelease>i" },
    },

    __DEBUG = {
      ReloadLaunchJsonDebug = { "BufWritePost", "launch.json", "lua require('dap.ext.vscode').load_launchjs()" },
    },

    __LAZYGIT = {
      -- OpenLgAfterGitCommit = {
      --   "BufWrite",
      --   "gitcommit",
      --   "lua require('lvim.core.terminal')._exec_toggle({ cmd = 'lazygit' })",
      -- },
      OpenLgAfterGitCommit = {
        "BufWrite",
        "gitcommit",
        "lua print('lvim.core.terminal')",
      },
    },
  }
end

return M
