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
        filetypes = { "json" },
      },
    },
    configure = function()
      lvim.extensions.cmp.to_setup = {
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          -- { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "nvim_lua" },
          -- { name = "omni" },
          { name = "buffer" },
          -- { name = "fuzzy_buffer" },

          { name = "calc" },
          { name = "env" },

          { name = "git" },
          { name = "npm" },

          { name = "rg", option = { additional_arguments = "--ignore-case" }, keyword_length = 3 },
        },

        formatting = {
          source_names = {
            nvim_lsp = "(LSP)",
            emoji = "(Emoji)",
            path = "(Path)",
            calc = "(Calc)",
            cmp_tabnine = "(Tabnine)",
            vsnip = "(Snippet)",
            luasnip = "(Snippet)",
            buffer = "(Buffer)",
            fuzzy_buffer = "(Buffer-FZF)",
            git = "(GIT)",
            omni = "(OMNI)",
            npm = "(NPM)",
            rg = "(RG)",
            tmux = "(TMUX)",
            nvim_lsp_signature_help = "(SH)",
          },
        },
      }
    end,
    to_inject = function()
      return {
        cmp = require("cmp"),
      }
    end,
    on_setup = function(config)
      for key, e in pairs(config.setup) do
        local extension = require(key)

        extension.setup(e)
      end

      -- setup lua snip
      local utils = require("lvim.utils")
      local paths = {}
      paths[#paths + 1] = join_paths(get_data_dir(), "site", "pack", "packer", "start", "friendly-snippets")
      local user_snippets = join_paths(get_config_dir(), "snippets")
      if utils.is_directory(user_snippets) then
        paths[#paths + 1] = user_snippets
      end
      require("luasnip.loaders.from_lua").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    on_done = function(config)
      local cmp = config.inject.cmp

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({
          -- Your configuration here.
        }),
        sources = {
          { name = "cmdline" },
        },
      })

      -- fuzzy buffer
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline({
          -- Your configuration here.
        }),
        sources = cmp.config.sources({
          { name = "fuzzy_buffer" },
        }),
      })

      cmp.setup.cmdline("?", {
        mapping = cmp.mapping.preset.cmdline({
          -- Your configuration here.
        }),
        sources = cmp.config.sources({
          { name = "fuzzy_buffer" },
        }),
      })

      -- dap
      cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
        sources = {
          { name = "dap" },
        },
      })
    end,
  })
end

return M
