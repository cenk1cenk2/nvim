local opts = {
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
  handlers = {
    ["$/getToken"] = function()
      return {}
    end,
    ["$/getCredentials"] = function()
      return {}
    end,
  },
}

return opts
