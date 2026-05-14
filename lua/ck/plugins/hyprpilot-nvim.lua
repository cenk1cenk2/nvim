-- https://github.com/hyprpilot/hyprpilot.nvim
local M = {}

local log = require("ck.log")

M.name = "hyprpilot/hyprpilot.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, vim.tbl_contains(nvim.lsp.ai.chat.provider, "hyprpilot"), {
    plugin = function()
      ---@type Plugin
      return {
        "hyprpilot/hyprpilot.nvim",
        dir = "~/development/hyprpilot.nvim",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "hyprpilot",
        "hyprpilot_header",
        "hyprpilot_input",
        "hyprpilot_permission_row",
        "hyprpilot_queue_strip",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            title = "Hyprpilot",
            ft = {
              "hyprpilot_header",
              "hyprpilot",
              "hyprpilot_permission_row",
              "hyprpilot_queue_strip",
              "hyprpilot_input",
            },
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.5
                end

                return 180
              end,
            },
            wo = { winbar = false },
          },
        })

        return c
      end)

      require("ck.setup").setup_callback(require("ck.plugins.blink-cmp").name, function(c)
        c.sources.providers.hyprpilot = {
          module = "hyprpilot.completion.blink",
          name = "hyprpilot",
        }

        c.sources.per_filetype.hyprpilot_input = function()
          return { "hyprpilot", "path", "ripgrep" }
        end

        return c
      end)
    end,
    setup = function()
      ---@type hyprpilot.Config
      return {
        log_level = vim.log.levels.DEBUG,
        with_config = {
          {
            mcps = {
              {
                servers = {
                  ["hyprpilot-nvim"] = {
                    command = "uvx",
                    args = { "hyprpilot-nvim-mcp" },
                    env = {
                      NVIM_LISTEN_ADDRESS = vim.v.servername,
                    },
                  },
                },
              },
            },
          },
        },
      }
    end,
    on_setup = function(c)
      require("hyprpilot").setup(c)

      -- Register built-in MCP tool categories so the daemon-side
      -- agent (Claude / opencode / ...) can call into our live LSP,
      -- editor state, and `vim.ui.open` through the `hyprpilot-nvim`
      -- MCP bridge. Daemon-side profile allow / deny lists gate
      -- per-tool policy.
      require("hyprpilot.mcp.lsp").register_all()
      require("hyprpilot.mcp.editor").register_all()
      require("hyprpilot.mcp.open").register_all()

      if vim.v.servername == nil or vim.v.servername == "" then
        log:warn("hyprpilot: v:servername is empty — MCP bridge will not connect")
      end
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        -- chat window
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("hyprpilot").toggle()
          end,
          desc = "toggle chat [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "<Space>" }),
          function()
            require("hyprpilot.ui.window").focus()
          end,
          desc = "focus sidebar [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "o" }),
          function()
            require("hyprpilot.client").request("overlay/toggle", {}, nil, function(err)
              if err ~= nil then
                log:warn("hyprpilot: overlay/toggle failed: %s", err.message)
              end
            end)
          end,
          desc = "toggle daemon overlay [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "n" }),
          function()
            require("hyprpilot.palettes.attention").open()
          end,
          desc = "pick attention [hyprpilot]",
          mode = { "n" },
        },

        -- multi-instance
        {
          fn.wk_keystroke({ categories.COPILOT, "C" }),
          function()
            require("hyprpilot.palettes.profiles").open()
          end,
          desc = "spawn instance [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "F" }),
          function()
            require("hyprpilot.palettes.sessions").open()
          end,
          desc = "pick session [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("hyprpilot.instances").restart()
          end,
          desc = "restart current [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "X" }),
          function()
            require("hyprpilot.instances").shutdown()
          end,
          desc = "shutdown current [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "f" }),
          function()
            require("hyprpilot.palettes.instances").open()
          end,
          desc = "pick instance [hyprpilot]",
          mode = { "n" },
        },

        -- composer attachments
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            require("hyprpilot.ui.composer").attach_buffer()
          end,
          desc = "attach current buffer [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "D" }),
          function()
            local composer = require("hyprpilot.ui.composer")
            local list = composer.attachments()
            if #list == 0 then
              return
            end
            vim.ui.select(list, {
              prompt = "detach attachment",
              format_item = function(a)
                return a.title or a.slug
              end,
            }, function(choice)
              if choice ~= nil then
                composer.detach(choice.slug)
              end
            end)
          end,
          desc = "detach attachment [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "p" }),
          function()
            require("hyprpilot.ui.composer").attach_clipboard_image()
          end,
          desc = "attach clipboard image [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "A" }),
          function()
            require("hyprpilot.ui.composer").paste_buffer()
          end,
          desc = "paste buffer as code [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "A" }),
          function()
            require("hyprpilot.ui.composer").paste_selection()
          end,
          desc = "paste selection as code [hyprpilot]",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.COPILOT, "m" }),
          group = "adapter [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "m", "M" }),
          function()
            require("hyprpilot.palettes.modes").open()
          end,
          desc = "pick mode [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "m", "a" }),
          function()
            require("hyprpilot.palettes.models").open()
          end,
          desc = "pick model [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "m", "e" }),
          function()
            require("hyprpilot.palettes.effort").open()
          end,
          desc = "pick effort [hyprpilot]",
          mode = { "n" },
        },

        {
          fn.wk_keystroke({ categories.COPILOT, "Q" }),
          function()
            vim.cmd([[Lazy reload hyprpilot.nvim]])
          end,
          desc = "reload [hyprpilot]",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      return {
        --   {
        --     event = "User",
        --     group = "_hyprpilot_markview",
        --     pattern = "HyprpilotComposerSubmitted",
        --     callback = function(ev)
        --       local bufnr = ev.data and ev.data.bufnr
        --       if not bufnr then
        --         return
        --       end
        --
        --       -- Detach markview during streaming to avoid performance
        --       -- issues and treesitter query race conditions.
        --       pcall(require("markview.actions").detach, bufnr)
        --     end,
        --   },
        --   {
        --     event = "User",
        --     group = "_hyprpilot_markview",
        --     pattern = "HyprpilotChatRendered",
        --     callback = function(ev)
        --       local bufnr = ev.data and ev.data.bufnr
        --       if not bufnr then
        --         return
        --       end
        --
        --       -- Re-attach markview and render after each transcript tick.
        --       pcall(require("markview.actions").attach, bufnr)
        --       pcall(require("markview.actions").set_query, bufnr)
        --       pcall(require("markview.actions").render, bufnr)
        --     end,
        --   },
      }
    end,
  })
end

return M
