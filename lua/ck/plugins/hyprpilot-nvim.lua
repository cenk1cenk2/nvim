-- https://github.com/hyprpilot/hyprpilot.nvim
local M = {}

local log = require("ck.log")

M.name = "hyprpilot/hyprpilot.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "hyprpilot"), {
    plugin = function()
      ---@type Plugin
      return {
        "hyprpilot/hyprpilot.nvim",
        -- dir = "~/development/hyprpilot.nvim",
        -- commit = "19599401c5723ffe25af90f5e3e82171d6dde71e",
      }
    end,
    setup = function()
      ---@type hyprpilot.Config
      return {
        -- log_level = vim.log.levels.DEBUG,
      }
    end,
    on_setup = function(c)
      require("hyprpilot").setup(c)

      -- Register built-in MCP tool categories so the daemon-side
      -- agent (Claude / opencode / ...) can call into our live LSP,
      -- editor state, and `vim.ui.open` through the `hyprpilot-nvim`
      -- MCP bridge. Daemon-side profile allow / deny lists gate
      -- per-tool policy.
      require("hyprpilot.mcp.lsp").register_all()
      require("hyprpilot.mcp.editor").register_all()

      if vim.v.servername == nil or vim.v.servername == "" then
        log:warn("hyprpilot: v:servername is empty — MCP bridge will not connect")
      end
    end,
  })
end

return M
