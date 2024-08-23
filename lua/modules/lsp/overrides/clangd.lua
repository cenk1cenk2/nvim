local capabilities = require("core.lsp").common_capabilities()
capabilities.offsetEncoding = { "utf-16" }

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
