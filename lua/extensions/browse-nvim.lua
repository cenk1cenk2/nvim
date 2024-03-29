-- https://github.com/lalitmee/browse.nvim
local M = {}

local extension_name = "browse_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
    wk = function(_, categories)
      return {
        ["S"] = {
          function()
            require("browse").input_search()
          end,
          "search on google",
        },
      }
    end,
  })
end

return M
