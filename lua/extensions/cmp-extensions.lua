-- https://github.com/petertriho/cmp-git
-- https://github.com/David-Kunz/cmp-npm
-- https://github.com/hrsh7th/cmp-cmdline
-- https://github.com/tzachar/cmp-fuzzy-buffer
local M = {}

local extension_name = "cmp_extensions"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
    configure = function()
      lvim.builtin.cmp.sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "crates" },

        { name = "git" },

        { name = "npm" },

        { name = "rg", option = { additional_arguments = "--ignore-case" }, keyword_length = 3 },

        { name = "treesitter" },

        { name = "tmux" },

        -- { name = "cmp_tabnine" },
      }

      lvim.builtin.cmp.formatting.source_names = {
        nvim_lsp = "(LSP)",
        emoji = "(Emoji)",
        path = "(Path)",
        calc = "(Calc)",
        cmp_tabnine = "(Tabnine)",
        vsnip = "(Snippet)",
        luasnip = "(Snippet)",
        buffer = "(Buffer)",
        git = "(GIT)",
        npm = "(NPM)",
        rg = "(RG)",
        orgmode = "(ORG)",
        tmux = "(TMUX)",
      }
    end,
    to_inject = function()
      return {
        cmp = require "cmp",
      }
    end,
    on_setup = function(config)
      for key, e in pairs(config.setup) do
        local extension = require(key)

        extension.setup(e)
      end
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
