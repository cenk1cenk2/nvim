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
        { "neovim/nvim-lspconfig", lazy = false },
        { "tamago324/nlsp-settings.nvim", lazy = false },
        { "jose-elias-alvarez/null-ls.nvim", lazy = false },
        { "b0o/schemastore.nvim", lazy = false },
        { "folke/neodev.nvim", ft = { "lua" } },
      }
    end,
  })
end

return M
