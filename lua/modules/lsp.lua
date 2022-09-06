local M = {}

local Log = require "lvim.core.log"

function M.LspSetup()
  local servers = require("lspconfig.util").available_servers()

  vim.ui.select(servers, {
    prompt = "LSP server to start:",
  }, function(server)
    if server == nil then
      Log:warn "Nothing to compare."

      return
    end

    require("lvim.lsp.manager").setup(server)
    Log:info(string.format("Started LSP server: %s", server))
  end)
end

function M.setup()
  require("utils.setup").run {
    commands = {
      {
        name = "LspSetup",
        fn = function()
          M.LspSetup()
        end,
      },
    },
  }
end

return M
