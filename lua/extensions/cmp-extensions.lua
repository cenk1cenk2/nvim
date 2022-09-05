-- https://github.com/petertriho/cmp-git
-- https://github.com/David-Kunz/cmp-npm
-- https://github.com/hrsh7th/cmp-cmdline
-- https://github.com/tzachar/cmp-fuzzy-buffer
local M = {}

local setup = require "utils.setup"

local extension_name = "cmp_extensions"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function()
      return {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-vsnip",
        "petertriho/cmp-git",
        "David-Kunz/cmp-npm",
        "hrsh7th/cmp-cmdline",
        "davidsierradz/cmp-conventionalcommits",
        "tzachar/cmp-fuzzy-buffer",
        "lukas-reineke/cmp-rg",
        -- { "tzachar/cmp-tabnine", run = "./install.sh" },
      }
    end,
    extensions = {
      {
        name = "cmp_git",
        -- defaults
        filetypes = { "gitcommit" },
        remotes = { "upstream", "origin" },
      },
      {
        name = "cmp-npm",
      },
    },
    on_setup = function(config)
      for _, e in pairs(config.extensions) do
        local extension = require(e.name)

        extension.setup(e)
      end
    end,
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

return M
