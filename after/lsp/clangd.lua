local capabilities = require("ck.lsp.handlers").capabilities()
capabilities.offsetEncoding = { "utf-16" }

---@type vim.lsp.ClientConfig
return {
  filetypes = {
    "c",
    "cpp",
    "objc",
    "objcpp",
    "cuda",
    "proto",
  },
  capabilities = capabilities,
}
