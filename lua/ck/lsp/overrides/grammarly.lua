---@module 'lspconfig'
---@type lspconfig.options.grammarly
return {
  cmd = { "fnm", "exec", "--using=16", "--", "grammarly-languageserver", "--stdio" },
  filetypes = { "markdown", "plaintext", "text", "gitcommit" },
  single_file_support = true,
  settings = {
    grammarly = {
      startTextCheckInPausedState = false,
      config = {
        documentDialect = "american",
        documentDomain = "business",
        suggestions = {
          MissingSpaces = false,
          OxfordComma = true,
        },
      },
    },
  },
}
