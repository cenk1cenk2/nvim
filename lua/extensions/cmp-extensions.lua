local M = {}

local setup = require "utils.setup"

local extension_name = "cmp_extensions"

function M.config()
  setup.define_extension(extension_name, true, {
    extensions = {
      {
        name = "cmp_git",
        -- defaults
        filetypes = { "gitcommit" },
        remotes = { "upstream", "origin" }, -- in order of most to least prioritized
      },
      {
        name = "cmp-npm",
      },
    },
    on_config_done = function()
      local cmp = require "cmp"

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

function M.setup()
  local config = setup.get_config(extension_name)

  for _, e in pairs(config.extensions) do
    local extension = require(e.name)

    extension.setup(e)
  end

  setup.on_setup_done(config)
end

return M
