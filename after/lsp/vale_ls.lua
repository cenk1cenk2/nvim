local config = join_paths(vim.fn.stdpath("config"), "utils/linter-config", "vale.ini")

---@type vim.lsp.ClientConfig
return {
  filetypes = { "markdown", "plaintext", "text", "gitcommit", "" },
  -- on_attach = function(client, bufnr)
  --   require("ck.lsp.handlers").on_attach(client, bufnr)
  --   require("ck.utils.job")
  --     .create({
  --       command = "vale",
  --       args = { "--config", config, "sync" },
  --     })
  --     :start()
  -- end,
  init_options = {
    installVale = true,
    configPath = config,
    syncOnStartup = true,
  },
}
