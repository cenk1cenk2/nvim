local Log = require "lvim.core.log"
local job = require "utils.job"
local table_utils = require "lvim.utils.table"

local M = {}

function M.run_markdown_toc()
  local servers = require "nvim-lsp-installer.servers"
  local server_available, server = servers.get_server "markdown_toc"

  if not server_available then
    Log:error(("Server %s is not available."):format "markdown-toc")

    return
  end

  job.spawn {
    command = table.concat(server._default_options.cmd),
    args = table_utils.merge(server._default_options.extra_args, { vim.fn.expand "%" }),
    env = server._default_options.cmd_env,
  }
end

function M.run_md_printer()
  job.spawn { command = "md-printer", args = { vim.fn.expand "%" } }
end

M.setup = function()
  require("utils.command").wrap_to_command {
    { "RunMarkdownToc", [[lua require('modules.lsp-commands').run_markdown_toc()]] },
    { "RunMdPrinter", [[lua require('modules.lsp-commands').run_md_printer()]] },
  }
end

return M
