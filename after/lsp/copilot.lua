---@type vim.lsp.ClientConfig
return {
  condition = function()
    return nvim.lsp.ai.provider.completion == "copilot"
  end,
  flags = {
    debounce_text_changes = nvim.lsp.ai.copilot.debounce,
  },
  -- filetypes = nvim.lsp.ai.copilot.filetypes
  settings = {
    github = {
      copilot = {
        selectedCompletionModel = nvim.lsp.ai.model.completion,
      },
    },
  },
}
