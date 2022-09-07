--
local M = {}

local extension_name = "treesitter_extensions"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    packer = function()
      return {
        {
          "JoosepAlviste/nvim-ts-context-commentstring",
          event = "BufReadPost",
          requires = { "nvim-treesitter/nvim-treesitter" },
        },
        { "p00f/nvim-ts-rainbow", run = ":TSUpdate", requires = { "nvim-treesitter/nvim-treesitter" } },
        { "windwp/nvim-ts-autotag", requires = { "nvim-treesitter/nvim-treesitter" } },
        { "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } },
      }
    end,
  })
end

return M
