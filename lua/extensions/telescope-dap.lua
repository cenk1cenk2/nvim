-- https://github.com/nvim-telescope/telescope-dap.nvim
local M = {}

M.name = "nvim-telescope/telescope-dap.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.DEBUG, "f" }),
          function()
            require("telescope").extensions.dap.configurations(require("telescope.themes").get_dropdown({}))
          end,
          desc = "configurations",
          mode = { "v" },
        },
      }
    end,
  })
end

return M
