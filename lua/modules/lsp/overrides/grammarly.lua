local opts = {
  filetypes = { "markdown", "plaintext", "text" },
  single_file_support = true,
  settings = {
    grammarly = {
      startTextCheckInPausedState = false,
      config = {
        documentDialect = "american",
        documentDomain = "business",
        suggestions = {
          MissingSpaces = false,
        },
      },
    },
  },
}

return opts
