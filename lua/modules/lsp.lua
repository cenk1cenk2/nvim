local M = {}

local Log = require("lvim.core.log")

function M.lsp_setup()
  local servers = require("lspconfig.util").available_servers()

  vim.ui.select(servers, {
    prompt = "LSP server to start:",
  }, function(server)
    if server == nil then
      Log:warn("Nothing to compare.")

      return
    end

    require("lvim.lsp.manager").setup(server)
    Log:info(("Started LSP server: %s"):format(server))
  end)
end

function M.setup()
  require("utils.setup").init({
    commands = {
      {
        name = "LspSetup",
        fn = function()
          M.lsp_setup()
        end,
      },
    },
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          ["r"] = {
            function()
              M.lsp_setup()
            end,
            "setup lsp for this buffer",
          },
        },
      }
    end,
  })
end

return M
