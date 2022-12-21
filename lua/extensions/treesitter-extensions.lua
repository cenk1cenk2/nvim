--
local M = {}

local extension_name = "treesitter_extensions"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "JoosepAlviste/nvim-ts-context-commentstring",
          dependencies = { "nvim-treesitter/nvim-treesitter" },
        },
        {
          "p00f/nvim-ts-rainbow",
          build = ":TSUpdate",
          dependencies = { "nvim-treesitter/nvim-treesitter" },
        },
        {
          "windwp/nvim-ts-autotag",
          dependencies = { "nvim-treesitter/nvim-treesitter" },
        },
        -- {
        --   "nvim-treesitter/playground",
        --   after = { "nvim-treesitter" },
        -- },
      }
    end,
  })
end

return M
