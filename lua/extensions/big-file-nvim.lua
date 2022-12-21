-- https://github.com/LunarVim/bigfile.nvim
local M = {}

local extension_name = "big_file_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "LunarVim/bigfile.nvim",
        init = function()
          require("utils.setup").plugin_init "big_file_nvim"
        end,
        enabled = config.active,
      }
    end,
    setup = {
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
      pattern = { "*" }, -- autocmd pattern
      features = { -- features to disable
        "indent_blankline",
        "illuminate",
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
        "filetype",
      },
    },
    on_setup = function(config)
      require("bigfile").config(config.setup)
    end,
  })
end

return M
