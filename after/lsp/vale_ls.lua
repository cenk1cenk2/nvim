local config = join_paths(vim.fn.stdpath("config"), "utils/linter-config", "vale.ini")

---@type vim.lsp.ClientConfig
return {
  filetypes = { "markdown", "plaintext", "text", "gitcommit", "" },
  on_init = function(client, bufnr)
    require("ck.lsp.handlers").on_init(client, bufnr)
    require("ck.utils.job")
      .create({
        command = "vale",
        args = { "--config", config, "sync" },
        on_failure = function(j, return_val)
          require("ck.log").error("Vale sync failed: %s", j:result())
        end,
      })
      :start()
  end,
  init_options = {
    installVale = true,
    configPath = config,
    syncOnStartup = true,
  },
}
