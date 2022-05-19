local Log = require "lvim.core.log"
local spawn = require "modules.spawn"

local M = {}

function M.run_markdown_toc()
  local servers = require "nvim-lsp-installer.servers"
  local server_available, server = servers.get_server "markdown_toc"

  local cmd = "node_modules/.bin/markdown-toc"
  local opts = { args = { vim.fn.expand "%:p", "--bullets=-", "-i" }, cwd = server.root_dir }

  if not server_available then
    Log:error(("Server %s is not available."):format(cmd))

    return
  end

  spawn.run_command(cmd, opts)
end

M.setup = function()
  require("utils.command").wrap_to_command {
    { "RunMarkdownToc", [[lua require('modules.lsp-commands').run_markdown_toc()]] },
  }
end

return M
