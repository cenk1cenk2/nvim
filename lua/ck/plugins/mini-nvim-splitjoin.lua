-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-splitjoin.md
local M = {}

M.name = "echasnovski/mini.splitjoin"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "echasnovski/mini.splitjoin",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        -- Module mappings. Use `''` (empty string) to disable one.
        mappings = {
          toggle = "", -- We'll define our own
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

          -- Array of Lua patterns for sub-regions to exclude.
          -- Enables correct processing of nested brackets and quotes.
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
    on_setup = function(c)
      require("mini.splitjoin").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "gJ",
          function()
            require("mini.splitjoin").toggle()
          end,
          desc = "toggle split/join",
          mode = { "n", "v" },
        },
        -- {
        --   "gS",
        --   function()
        --     require("mini.splitjoin").split()
        --   end,
        --   desc = "split arguments",
        --   mode = { "n", "v" },
        -- },
        -- {
        --   "gK",
        --   function()
        --     require("mini.splitjoin").join()
        --   end,
        --   desc = "join arguments",
        --   mode = { "n", "v" },
        -- },
      }
    end,
  })
end

return M
