-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-splitjoin.md
local M = {}

local extension_name = "mini_nvim_splitjoin"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "echasnovski/mini.splitjoin",
        event = "BufReadPost",
      }
    end,
    setup = function()
      return {
        -- Module mappings. Use `''` (empty string) to disable one.
        -- Created for both Normal and Visual modes.
        mappings = {
          toggle = "",
          split = "",
          join = "",
        },

        -- Detection options: where split/join should be done
        detect = {
          -- Array of Lua patterns to detect region with arguments.
          -- Default: { '%b()', '%b[]', '%b{}' }
          brackets = nil,

          -- String Lua pattern defining argument separator
          separator = ",",

          -- Array of Lua patterns for sub-regions to exclude separators from.
          -- Enables correct detection in presence of nested brackets and quotes.
          -- Default: { '%b()', '%b[]', '%b{}', '%b""', "%b''" }
          exclude_regions = nil,
        },

        -- Split options
        split = {
          hooks_pre = {},
          hooks_post = {},
        },

        -- Join options
        join = {
          hooks_pre = {},
          hooks_post = {},
        },
      }
    end,
    on_setup = function(config)
      require("mini.splitjoin").setup(config.setup)
    end,
    keymaps = function()
      return {
        n = {
          ["gJ"] = {
            function()
              require("mini.splitjoin").toggle()
            end,
            { desc = "split lines" },
          },
        },
      }
    end,
  })
end

return M
