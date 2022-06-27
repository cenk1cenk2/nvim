local opts = {
  filetypes = { "markdown", "plaintext", "text" },
  single_file_support = true,
  settings = {
    grammarly = {
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
  init_options = {
    clientId = "",
    startTextCheckInPausedState = false,
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
