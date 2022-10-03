-- https://github.com/folke/noice.nvim
local M = {}

local extension_name = "noice_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "folke/noice.nvim",
        event = "VimEnter",
        config = function()
          require("utils.setup").packer_config "noice_nvim"
        end,
        requires = {
          "MunifTanjim/nui.nvim",
        },
        disable = not config.active,
      }
    end,
    setup = {},
    on_setup = function(config)
      require("noice").setup(config.setup)
    end,
    wk = {
      ["h"] = { ":Noice<CR>", "messages" },
    },
  })
end

return M
