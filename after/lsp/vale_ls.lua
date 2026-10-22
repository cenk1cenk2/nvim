local config = join_paths(vim.fn.stdpath("config"), "utils/linter-config", "vale.ini")

---@type vim.lsp.ClientConfig
return {
  filetypes = { "markdown", "plaintext", "text", "gitcommit", "" },
  init_options = {
    installVale = true,
    configPath = config,
    syncOnStartup = true,
  },
}
