-- https://github.com/Saghen/blink.cmp
local M = {}

M.name = "Saghen/blink.cmp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Saghen/blink.cmp",
        version = "*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
          -- https://github.com/mikavilpas/blink-ripgrep.nvim
          { "mikavilpas/blink-ripgrep.nvim" },
          -- https://github.com/rafamadriz/friendly-snippets
          { "rafamadriz/friendly-snippets" },
          -- https://github.com/L3MON4D3/LuaSnip
          { "L3MON4D3/LuaSnip" },
          -- https://github.com/saghen/blink.compat
          {
            "saghen/blink.compat",
            config = function()
              require("blink.compat").setup({
                impersonate_nvim_cmp = false,
              })
            end,
          },
          -- https://github.com/tzachar/cmp-fuzzy-buffer
          {
            "cenk1cenk2/cmp-fuzzy-buffer",
            branch = "patch-1",
          },
          -- https://github.com/cenk1cenk2/cmp-zsh
          {
            "cenk1cenk2/cmp-zsh",
            config = function()
              require("cmp_zsh").setup({
                zshrc = true,
                filetypes = { "zsh", "bash", "sh" },
                env = {
                  ZNAP_HEADLESS = "1",
                },
              })
            end,
          },
          -- https://github.com/petertriho/cmp-git
          {
            "petertriho/cmp-git",
            config = function()
              require("cmp_git").setup({
                filetypes = { "gitcommit" },
                remotes = { "upstream", "origin" },
                gitlab = {
                  hosts = {
                    "gitlab.kilic.dev",
                  },
                },
              })
            end,
          },
          -- https://github.com/David-Kunz/cmp-npm
          {
            "David-Kunz/cmp-npm",
            config = function()
              require("cmp-npm").setup({
                filetypes = { "json" },
              })
            end,
          },
          -- https://github.com/Snikimonkd/cmp-go-pkgs
          {
            -- "Snikimonkd/cmp-go-pkgs",
            "cenk1cenk2/cmp-go-pkgs",
            branch = "patch-1",
          },
          -- https://github.com/wookayin/cmp-omni
          {
            "wookayin/cmp-omni",
            branch = "fix-return",
          },
          {
            -- https://github.com/fang2hou/blink-copilot
            "fang2hou/blink-copilot",
            enabled = vim.tbl_contains(nvim.lsp.ai.completion.provider, "cmp"),
            init = function()
              require("ck.setup").setup_callback(require("ck.plugins.blink-cmp").name, function(c)
                c.sources.providers.copilot = {
                  name = "copilot",
                  module = "blink-copilot",
                  score_offset = 100,
                  async = true,
                  opts = {
                    kind_icon = nvim.ui.icons.misc.Robot,
                  },
                }

                local cb = c.sources.default

                c.sources.default = function(ctx)
                  return vim.list_extend({ "copilot" }, cb(ctx))
                end

                -- TODO: this does not have a way to add it back to the default configuration which is wierd, if it had this it would have been more convient to use this
                -- require("ck.setup").hook_callback(require("ck.plugins.blink-cmp").name, { require("ck.setup").HOOK_EVENTS.HAS_FINISHED_ON_DONE }, function(event)
                --   require("blink-cmp").add_source_provider("copilot", {
                --     name = "copilot",
                --     module = "blink-copilot",
                --     score_offset = 100,
                --     async = true,
                --     opts = {
                --       kind_icon = nvim.ui.icons.misc.Robot,
                --     },
                --   })

                return c
              end)
            end,
          },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "blink-cmp-menu",
        "blink-cmp-documentation",
      })
    end,
    setup = function()
      ---@type blink.cmp.Config
      return {
        sources = {
          default = function(ctx)
            return {
              "lsp",
              "lazydev",
              "zsh",
              "omni",
              "npm",
              "git",
              "go_pkgs",
              "snippets",
              "path",
              "buffer",
              "ripgrep",
            }
          end,
          per_filetype = {},
          providers = {
            lsp = {
              score_offset = 10,
            },
            lazydev = {
              name = "LD",
              module = "lazydev.integrations.blink",
              score_offset = 15,
            },
            ripgrep = {
              module = "blink-ripgrep",
              name = "RG",
              timeout_ms = 5000,
              async = true,
              opts = {
                prefix_min_len = 3,
                backend = {
                  ripgrep = {
                    project_root_fallback = false,
                  },
                },
              },
            },
            zsh = {
              module = "blink.compat.source",
              name = "zsh",
              async = true,
            },
            git = {
              module = "blink.compat.source",
              name = "git",
              async = true,
            },
            npm = {
              module = "blink.compat.source",
              name = "npm",
              async = true,
            },
            go_pkgs = {
              module = "blink.compat.source",
              async = true,
              name = "go_pkgs",
            },
            omni = {
              module = "blink.compat.source",
              name = "omni",
              opts = { disable_omnifuncs = { "v:lua.vim.lsp.omnifunc", "sqlcomplete#Complete" } },
              async = true,
            },
            fuzzy_buffer = {
              module = "blink.compat.source",
              async = true,
              name = "fuzzy_buffer",
            },
          },
        },
        cmdline = {
          completion = {
            ghost_text = {
              enabled = false,
            },
          },
          sources = function()
            local type = vim.fn.getcmdtype()

            if vim.tbl_contains({ "/", "?" }, type) then
              return {
                "fuzzy_buffer",
              }
            elseif vim.tbl_contains({ ":", "@" }, type) then
              -- local cmdline = vim.fn.getcmdline()
              -- if cmdline:match("^lua") then
              --   return {
              --     "lsp",
              --     "lazydev",
              --   }
              -- elseif cmdline:match("^!") then
              --   return {
              --     "zsh",
              --   }
              -- end

              return {
                "cmdline",
              }
            end

            return {}
          end,
        },

        fuzzy = {
          implementation = "rust",
          -- max_typos = 0,
          use_proximity = true,
          frecency = {
            enabled = false,
          },
          sorts = {
            "exact",
            "score",
            -- "label",
            -- "kind",
            "sort_text",
          },
        },
        completion = {
          keyword = {
            range = "full",
          },
          ghost_text = {
            enabled = false,
          },
          accept = {
            create_undo_point = true,
            ---TODO: enable this when cmp or this fixes it: https://github.com/windwp/nvim-autopairs/issues/477
            auto_brackets = {
              enabled = false,
            },
          },
          list = {
            selection = {
              auto_insert = true,
              preselect = false,
            },
          },
          menu = {
            border = nvim.ui.border,
            min_width = 40,
            max_height = 10,
            draw = {
              components = {
                label = {
                  width = {
                    fill = true,
                    max = 60,
                  },
                },
                source_name = {
                  width = {
                    fixed = 4,
                  },
                  text = function(ctx)
                    return ctx.source_name
                  end,
                  ellipsis = false,
                },
                kind = {
                  width = {
                    max = 10,
                  },
                  text = function(ctx)
                    return ctx.kind
                  end,
                },
              },
              treesitter = { "lsp", "buffer", "fuzzy_buffer", "ripgrep" },
              columns = {
                { "kind_icon", gap = 1 },
                { "label", "label_description", gap = 1 },
                { "kind", "source_name", gap = 1 },
              },
            },
          },
          documentation = {
            window = {
              border = nvim.ui.border,
              max_height = 15,
              min_width = 40,
              max_width = 120,
            },
            auto_show = true,
            -- auto_show_delay_ms = 150,
            -- update_delay_ms = 150,
            treesitter_highlighting = true,
          },
        },
        signature = {
          enabled = true,
          window = {
            border = nvim.ui.border,
            max_height = 15,
            min_width = 40,
            max_width = 120,
            treesitter_highlighting = true,
          },
        },
        snippets = {
          preset = "luasnip",
          -- expand = function(snippet)
          --   require("luasnip").lsp_expand(snippet)
          -- end,
          -- active = function(filter)
          --   if filter and filter.direction then
          --     return require("luasnip").jumpable(filter.direction)
          --   end
          --
          --   return require("luasnip").in_snippet()
          -- end,
          -- jump = function(direction)
          --   require("luasnip").jump(direction)
          -- end,
        },
        appearance = {
          kind_icons = nvim.ui.icons.kind,
        },
        keymap = {
          ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
          ["<CR>"] = { "accept", "fallback" },
          ["<C-e>"] = { "cancel", "hide", "fallback" },

          ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },

          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },

          ["<C-b>"] = { "scroll_documentation_up", "fallback" },
          ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
      }
    end,
    on_setup = function(c)
      require("blink-cmp").setup(c)
    end,
    on_done = function()
      -- setup lua snip
      local paths = {}

      table.insert(paths, join_paths(require("ck.loader").plugins_dir, "friendly-snippets"))

      local user_snippets = join_paths(get_config_dir(), "snippets")
      if is_directory(user_snippets) then
        table.insert(paths, user_snippets)
      end

      require("luasnip.loaders.from_lua").lazy_load({ paths = paths })
      require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        -- {
        --   event = "User",
        --   pattern = "BlinkCmpMenuOpen",
        --   group = "_blink",
        --   callback = function(e)
        --     if vim.lsp.inline_completion.is_enabled({ bufnr = e.buf }) then
        --       vim.lsp.inline_completion.enable(false, { bufnr = e.buf })
        --     end
        --   end,
        -- },
        -- {
        --   event = "User",
        --   pattern = "BlinkCmpMenuClose",
        --   group = "_blink",
        --   callback = function(e)
        --     vim.lsp.inline_completion.enable(require("ck.setup").evaluate_property(nvim.lsp.features.inline_completion.enabled), { bufnr = e.buf })
        --   end,
        -- },
      }
    end,
  })
end

return M
