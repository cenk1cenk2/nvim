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
      require("copilot-lsp.nes").lsp_on_init(client, au)
    end,
  })
end

return config
