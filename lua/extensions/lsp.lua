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
        { "neovim/nvim-lspconfig" },
        { "tamago324/nlsp-settings.nvim" },
        { "jose-elias-alvarez/null-ls.nvim" },
        { "b0o/schemastore.nvim" },
        { "folke/neodev.nvim", ft = { "lua" } },
      }
    end,
  })
end

return M
