-- https://github.com/saecki/crates.nvim
local M = {}

M.name = "saecki/crates.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "saecki/crates.nvim",
        event = {
          {
            event = { "BufReadPre" },
            pattern = { "Cargo.toml" },
          },
        },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.blink-cmp").name, function(c)
        c.sources.providers.crates = {
          module = "blink.compat.source",
          name = "crates",
        }

        local cb = c.sources.default

        c.sources.per_filetype["toml"] = function(ctx)
          return vim.list_extend({ "crates" }, cb(ctx))
        end

        return c
      end)
    end,
    setup = function()
      ---@type crates.UserConfig
      return {
        lsp = {
          enabled = false,
          on_attach = function(client, bufnr)
            require("ck.lsp.handlers").on_attach(client, bufnr)
          end,
          actions = true,
          completion = true,
          hover = true,
        },
        neoconf = {
          enabled = true,
        },
        date_format = "%Y%m%d",
        popup = {
          autofocus = true,
          border = nvim.ui.border,
        },
      }
    end,
    on_setup = function(c)
      require("crates").setup(c)
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").init_with({ "BufRead" }, { "Cargo.toml" }, function(event)
          return {
            keymaps = function(_, fn)
              ---@type KeymapMappings
              return {
                {
                  fn.local_keystroke({ "t" }),
                  function()
                    require("crates").toggle()
                  end,
                  desc = "toggle ui",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "Q" }),
                  function()
                    require("crates").reload()
                  end,
                  desc = "reload",
                  buffer = event.buf,
                },
                {
                  fn.local_keystroke({ "k" }),
                  function()
                    if require("crates").popup_available() then
                      require("crates").show_popup()
                    end
                  end,
                  desc = "reload",
                  buffer = event.buf,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

return M
