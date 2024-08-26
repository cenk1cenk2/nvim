local capabilities = require("ck.lsp.handlers").capabilities()
capabilities.offsetEncoding = { "utf-16" }

---@module "lspconfig"
---@type lspconfig.options.clangd
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
