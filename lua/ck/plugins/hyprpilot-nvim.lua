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

      require("hyprpilot.mcp.lsp").register()
      require("hyprpilot.mcp.editor").register({
        disabled_filetypes = nvim.disabled_filetypes,
        disabled_buffer_types = nvim.disabled_buffer_types,
      })

      if vim.v.servername == nil or vim.v.servername == "" then
        log:warn("hyprpilot: v:servername is empty — MCP bridge will not connect")
      end
    end,
  })
end

return M
