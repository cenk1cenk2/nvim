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
        preferredModel = nvim.lsp.ai.model.nes,
      },
    },
  },
}

return config
