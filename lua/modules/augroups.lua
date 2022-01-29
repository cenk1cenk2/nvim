local M = {}

M.setup = function()
  require("lvim.core.autocmds").define_augroups {
    custom_groups = {
      TerminalOpen = { "TermOpen", "*", "nnoremap <buffer><LeftRelease> <LeftRelease>i" },
      ReloadLaunchJsonDebug = { "BufWritePost", "launch.json", "lua require('dap.ext.vscode').load_launchjs()" },
      OpenLgAfterGitCommit = {
        "BufWritePost",
        "gitcommit",
        "lua print('imdat')",
      },
    },
  }
end

return M
