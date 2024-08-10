-- https://github.com/lalitmee/browse.nvim
local M = {}

M.name = "lalitmee/browse.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "lalitmee/browse.nvim",
      }
    end,
    setup = function()
      return {
        -- search provider you want to use
        provider = "google", -- default
      }
    end,
    on_setup = function(config)
      require("browse").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.FIND, "s" }),
          function()
            require("browse").input_search()
          end,
          desc = "search on google",
        },
      }
    end,
  })
end

return M
