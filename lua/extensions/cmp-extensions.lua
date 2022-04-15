local M = {}

local extension_name = "cmp_extensions"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    setup = {
      cmp_git = {
        name = "cmp_git",
        -- defaults
        filetypes = { "gitcommit" },
        remotes = { "upstream", "origin" }, -- in order of most to least prioritized
      },
      cmp_npm = {
        name = "cmp-npm",
      },
    },
  }
end

function M.setup()
  for _, setup in pairs(lvim.extensions[extension_name].setup) do
    local extension = require(setup.name)

    extension.setup(setup)
  end

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
end

return M
