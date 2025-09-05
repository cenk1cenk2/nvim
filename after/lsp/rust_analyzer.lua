-- local rust_tools_ok, rust_tools = pcall(require, "rust-tools")
-- local log = require "core.log"

---@type vim.lsp.ClientConfig
return {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
        enableExperimental = true,
      },
      check = {
        command = "clippy",
        extraEnv = { CARGO_TARGET_DIR = "/tmp/rust-analyzer" },
      },
      checkOnSave = {
        command = "clippy",
        -- extraArgs = { "--fix", "--allow-staged", "--allow-dirty" },
      },
      server = {
        extraEnv = {
          CARGO_TARGET_DIR = "/tmp/rust-analyzer",
        },
      },
    },
  },
}
