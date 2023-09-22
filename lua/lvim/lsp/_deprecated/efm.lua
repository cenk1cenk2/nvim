local M = {}

local lsp_utils = require("lvim.lsp.utils")

M.CLIENT_NAME = "efm"

function M.load(server)
  return require("modules.lsp.efm.config." .. server)
end

function M.register(configs, filetypes)
  lsp_utils.register_tools(
    lsp_utils.METHODS.FORMATTER,
    vim.tbl_filter(function(config)
      if config.method == lsp_utils.METHOD.FORMATTER then
        return true
      end

      return false
    end, configs),
    filetypes
  )

  lsp_utils.register_tools(
    lsp_utils.METHODS.LINTER,
    vim.tbl_filter(function(config)
      if config.method == lsp_utils.METHOD.LINTER then
        return true
      end

      return false
    end, configs),
    filetypes
  )
end

function M.setup()
  require("modules.lsp.efm").setup()

  lvim.lsp.tools.clients.formatters = M.CLIENT_NAME
  lvim.lsp.tools.clients.linters = M.CLIENT_NAME

  require("lvim.lsp.manager").setup(M.CLIENT_NAME)
end

return M
