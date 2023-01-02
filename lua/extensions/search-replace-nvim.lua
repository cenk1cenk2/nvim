-- https://github.com/roobert/search-replace.nvim
local M = {}

local extension_name = "search_replace_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "roobert/search-replace.nvim",
        -- cmd = {
        --   "SearchReplaceSingleBufferOpen",
        --   "SearchReplaceMultiBufferOpen",
        -- },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("search-replace").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        -- find and replace
        [categories.SEARCH] = {
          r = {
            name = "search-replace-nvim",
            s = {
              function()
                require("search-replace.single-buffer").open()
              end,
              "find and replace in single buffer",
            },
            v = {
              function()
                require("search-replace.single-buffer").cword()
              end,
              "find and replace in single buffer",
            },
          },
        },
      }
    end,
    keymaps = {
      x = {
        ["<C-r>"] = {
          function()
            require("search-replace.single-buffer").visual_charwise_selection({ range = true })
          end,
        },
      },
    },
  })
end

return M
