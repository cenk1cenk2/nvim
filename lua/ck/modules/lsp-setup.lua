local M = {}

local log = require("ck.log")

function M.lsp_setup()
  local servers = require("lspconfig.util").available_servers()

  vim.ui.select(servers, {
    prompt = "LSP server to start:",
  }, function(server)
    if server == nil then
      log:warn("Nothing to compare.")

      return
    end

    require("ck.lsp.loader").setup(server)
    log:info(("Started LSP server: %s"):format(server))
  end)
end

function M.setup()
  require("ck.setup").init({
    commands = {
      {
        "LspSetup",
        function()
          M.lsp_setup()
        end,
      },
    },
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LSP, "e" }),
          function()
            M.lsp_setup()
          end,
          desc = "setup lsp for this buffer",
        },
      }
    end,
  })
end

return M
