-- https://github.com/HakonHarnes/img-clip.nvim
local M = {}

M.name = "HakonHarnes/img-clip.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "HakonHarnes/img-clip.nvim",
        ft = { "markdown" },
      }
    end,
    setup = function()
      return {
        default = {
          dirpath = "assets",
          filename = "%Y%m%dT%H%M%S,",
        },
      }
    end,
    on_setup = function(c)
      require("img-clip").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "p" }),
          function()
            require("img-clip").paste_image()
          end,
          desc = "paste image",
        },
      }
    end,
  })
end

return M
