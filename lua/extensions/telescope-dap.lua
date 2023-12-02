-- https://github.com/nvim-telescope/telescope-dap.nvim
local M = {}

local extension_name = "telescope_dap"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-telescope/telescope-dap.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope dap" },
      }
    end,
    on_setup = function()
      require("telescope").load_extension("dap")
    end,
    wk = function(_, categories)
      return {
        [categories.DEBUG] = {
          ["l"] = { ":Telescope dap configurations<CR>", "configurations" },
        },
      }
    end,
  })
end

return M
