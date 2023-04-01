return {
  filetypes = { "markdown", "plaintext", "text", "gitcommit", "" },
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
