---@type vim.lsp.ClientConfig
local config = {
  condition = function()
    return nvim.lsp.ai.provider.completion == "copilot"
  end,
  flags = {
    debounce_text_changes = nvim.lsp.ai.copilot.debounce,
    allow_incremental_sync = true,
  },
  -- filetypes = nvim.lsp.ai.copilot.filetypes
  settings = {
    github = {
      copilot = {
        selectedCompletionModel = nvim.lsp.ai.model.completion,
      },
      nextEditSuggestions = {
        enabled = nvim.lsp.ai.copilot.nes.enabled,
      },
    },
  },
}

if nvim.lsp.ai.copilot.nes.enabled then
  config = vim.tbl_extend("force", config, {
    handlers = require("copilot-lsp.handlers"),
    on_init = function(client, bufnr)
      require("ck.lsp.handlers").on_init(client, bufnr)

      local au = vim.api.nvim_create_augroup("copilotlsp.init", { clear = true })

      if nvim.lsp.ai.copilot.nes.auto_suggest then
        local debounced_request = require("copilot-lsp.util").debounce(require("copilot-lsp.nes").request_nes, vim.g.copilot_nes_debounce or 500)
        vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
          callback = function()
            debounced_request(client)
          end,
          group = au,
        })
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local td_params = vim.lsp.util.make_text_document_params()
          client:notify("textDocument/didFocus", {
            textDocument = {
              uri = td_params.uri,
            },
          })
        end,
        group = au,
      })
    end,
  })
end

return config
