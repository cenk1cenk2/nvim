---@type vim.lsp.ClientConfig
return {
  condition = function()
    return nvim.lsp.ai.provider.completion == "copilot"
  end,
  -- filetypes = nvim.lsp.ai.copilot.filetypes
  settings = {
    github = {
      copilot = {
        selectedCompletionModel = nvim.lsp.ai.model.completion,
      },
    },
  },
}
