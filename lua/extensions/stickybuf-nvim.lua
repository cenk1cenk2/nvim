-- https://github.com/stevearc/stickybuf.nvim
local M = {}

local extension_name = "stickybuf_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "stevearc/stickybuf.nvim",
        config = function()
          require("utils.setup").plugin_init "stickybuf_nvim"
        end,
        enabled = config.active,
      }
    end,
    setup = {
      buftype = {
        [""] = false,
        acwrite = false,
        help = "buftype",
        nofile = false,
        nowrite = false,
        quickfix = "buftype",
        terminal = false,
        prompt = "bufnr",
      },
      wintype = {
        autocmd = false,
        popup = "bufnr",
        preview = false,
        command = false,
        [""] = false,
        unknown = false,
        floating = false,
      },
      filetype = {
        aerial = "filetype",
        nerdtree = "filetype",
        ["neo-tree"] = "filetype",
        ["neotest-summary"] = "filetype",
      },
    },
    on_setup = function(config)
      require("stickybuf").setup(config.setup)
    end,
  })
end

return M
