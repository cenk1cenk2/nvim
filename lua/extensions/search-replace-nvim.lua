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
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.SEARCH, "B" }),
          function()
            require("search-replace.single-buffer").open()
          end,
          desc = "[sr] find and replace in current buffer",
        },
        {
          fn.wk_keystroke({ categories.SEARCH, "V" }),
          function()
            require("search-replace.single-buffer").cword()
          end,
          desc = "[sr] find and replace cword in current buffer",
        },
      }
    end,
    keymaps = {
      {
        { "x" },

        ["<C-r>"] = {
          function()
            require("search-replace.visual-multitype").within({ range = true })
          end,
        },
      },
    },
  })
end

return M
