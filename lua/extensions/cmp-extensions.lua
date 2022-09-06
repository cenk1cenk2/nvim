-- https://github.com/petertriho/cmp-git
-- https://github.com/David-Kunz/cmp-npm
-- https://github.com/hrsh7th/cmp-cmdline
-- https://github.com/tzachar/cmp-fuzzy-buffer
local M = {}

local setup = require "utils.setup"

local extension_name = "cmp_extensions"

function M.config()
  setup.define_extension(extension_name, true, {
    setup = {
      cmp_git = {
        name = "git",
        -- defaults
        filetypes = { "gitcommit" },
        remotes = { "upstream", "origin" },
      },
      ["cmp-npm"] = {
        name = "npm",
      },
    },
    on_setup = function(config)
      for key, e in pairs(config.setup) do
        local extension = require(key)

        extension.setup(e)
      end
    end,
    to_inject = function()
      return {
        cmp = require "cmp",
      }
    end,
    on_done = function(config)
      local cmp = config.inject.cmp

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = {
          { name = "cmdline" },
        },
      })

      -- fuzzy buffer
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = cmp.config.sources {
          { name = "fuzzy_buffer" },
        },
      })

      cmp.setup.cmdline("?", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = cmp.config.sources {
          { name = "fuzzy_buffer" },
        },
      })
    end,
  })
end

return M
