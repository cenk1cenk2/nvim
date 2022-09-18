local opts = {
  filetypes = { "markdown", "plaintext", "text" },
  single_file_support = true,
  settings = {
    grammarly = {
      startTextCheckInPausedState = false,
      config = {
        hideUnavailablePremiumAlerts = true,
        audience = "knowledgeable",
        dialect = "american",
        domain = "general",
        style = "neutral",
        diagnostics = {
          ["[markdown]"] = {
            ignore = { "inlineCode", "code" },
          },
        },
      },
    },
  },
  init_options = {
    clientId = "client_BaDkMgx4X19X9UxxYRCXZo",
  },
  -- handlers = {
  --   ["$/getToken"] = function()
  --     return {}
  --   end,
  --   ["$/getCredentials"] = function()
  --     return {}
  --   end,
  -- },
}

return opts
