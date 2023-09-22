--
local M = {}

local extension_name = "lsp"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "neovim/nvim-lspconfig",
          event = "BufReadPre",
          init = false,
          config = function()
            require("lvim.lsp").setup()
          end,
        },
        {
          "tamago324/nlsp-settings.nvim",
          init = false,
          config = false,
        },
        {
          "b0o/schemastore.nvim",
          init = false,
          config = false,
        },
        {
          "folke/neodev.nvim",
          init = false,
          config = false,
          ft = { "lua" },
        },
      }
    end,
  })
end

return M
