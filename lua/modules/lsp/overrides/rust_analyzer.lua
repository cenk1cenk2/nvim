-- local rust_tools_ok, rust_tools = pcall(require, "rust-tools")
-- local Log = require "lvim.core.log"

return {
  -- Needed for inlayHints. Merge this table with your settings or copy
  -- it from the source if you want to add your own init_options.
  on_init = function(client, bufnr)
    -- local extension_name = "rust_tools_nvim"
    -- local config = lvim.extensions[extension_name]
    --
    -- if config.active then
    -- Log:debug "Setup additional rust-tools."
    --
    -- rust_tools_config.setup(config.setup)
    --
    -- rust_tools.setup_capabilities()
    -- -- setup on_init
    -- rust_tools.setup_on_init()
    -- -- setup root_dir
    -- rust_tools.setup_root_dir()
    -- -- setup handlers
    -- rust_tools.setup_handlers()
    -- -- setup user commands
    -- rust_tools.setup_commands()
    --
    -- lcommands.setup_lsp_commands()
    --
    -- if pcall(require, "dap") then
    --   rt_dap.setup_adapter()
    --
    --   Log:debug "Setup additional rust-tools dap."
    -- end
    -- end

    require("lvim.lsp").common_on_init(client, bufnr)
  end,
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
      },
      server = {
        extraEnv = {
          CARGO_TARGET_DIR = "/tmp/rust-analyzer",
        },
      },
    },
  },
}
