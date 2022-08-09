local Log = require "lvim.core.log"
local job = require "utils.job"
local table_utils = require "lvim.utils.table"

local M = {}

function M.run_markdown_toc()
  local server_name = "markdown-toc"
  local server = require("mason-registry").get_package(server_name)

  if not server:is_installed() then
    Log:error(("Server %s is not available."):format(server_name))

    return
  end

  local config = require("modules.lsp-config").get_lsp_default_config(server_name)

  print(vim.inspect(config))

  job.spawn {
    command = table.concat(config.command),
    args = table_utils.merge(config.args, { vim.fn.expand "%" }),
  }
end

function M.run_md_printer()
  job.spawn { command = "md-printer", args = { vim.fn.expand "%" } }
end

M.setup = function()
  require("utils.command").create_commands {
    {
      name = "RunMarkdownToc",
      fn = function()
        M.run_markdown_toc()
      end,
    },
    {
      name = "RunMdPrinter",
      fn = function()
        M.run_md_printer()
      end,
    },
  }
end

return M
