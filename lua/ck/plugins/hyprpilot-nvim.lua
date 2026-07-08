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
        -- dir = "~/development/hyprpilot.nvim",
        -- commit = "19599401c5723ffe25af90f5e3e82171d6dde71e",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "hyprpilot.markdown",
        "hyprpilot_header.markdown",
        "hyprpilot_composer.markdown",
        "hyprpilot_permission_row.markdown",
        "hyprpilot_queue_strip.markdown",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          { title = "Hyprpilot Header", ft = "hyprpilot_header.markdown", size = { height = 1 }, wo = { winbar = false } },
          {
            title = "Hyprpilot Chat",
            ft = "hyprpilot.markdown",
            size = {
              width = nvim.ui.dimensions.dock("width", "xl"),
            },
            wo = { winbar = false },
          },
          { title = "Hyprpilot Permissions", ft = "hyprpilot_permission_row.markdown", wo = { winbar = false } },
          { title = "Hyprpilot Queue", ft = "hyprpilot_queue_strip.markdown", wo = { winbar = false } },
          {
            title = "Hyprpilot Composer",
            ft = "hyprpilot_composer.markdown",
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

        c.sources.per_filetype["hyprpilot_composer"] = function()
          return { "hyprpilot", "path", "ripgrep", "snippets" }
        end

        return c
      end)
    end,
    setup = function()
      ---@type hyprpilot.Config
      return {
        -- log_level = vim.log.levels.DEBUG,
        with_config = {
          {
            mcps = {
              {
                mcpServers = {
                  ["hyprpilot-nvim"] = {
                    command = "uvx",
                    args = { "hyprpilot-nvim-mcp@latest" },
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
        {
          fn.wk_keystroke({ categories.SIDEKICK }),
          group = "hyprpilot",
          mode = { "n", "v" },
        },

        -- chat window
        {
          fn.wk_keystroke({ categories.SIDEKICK, "c" }),
          function()
            require("hyprpilot").toggle()
          end,
          desc = "toggle chat [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<Space>" }),
          function()
            require("hyprpilot.ui.window").focus()
          end,
          desc = "focus sidebar [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<CR>" }),
          function()
            require("hyprpilot.ui.window").scroll_to_end()
          end,
          desc = "jump to chat tail [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<BS>" }),
          function()
            require("hyprpilot.ui.window").focus({ target = "permission" })
          end,
          desc = "focus permission row [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "." }),
          function()
            require("hyprpilot.rpc.permissions").accept()
          end,
          desc = "accept permission [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "," }),
          function()
            require("hyprpilot.rpc.permissions").reject()
          end,
          desc = "reject permission [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "<DEL>" }),
          function()
            require("hyprpilot.ui.window").focus({ target = "queue" })
          end,
          desc = "focus queue row [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "o" }),
          function()
            require("hyprpilot.client").request(
              "overlay/show",
              {
                instanceId = require("hyprpilot.chat.window").active_instance(),
              },
              nil,
              function(err)
                if err ~= nil then
                  log:warn("hyprpilot: overlay/show failed: %s", err.message)
                end
              end
            )
          end,
          desc = "show daemon overlay [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "n" }),
          function()
            require("hyprpilot.palettes.attention").open()
          end,
          desc = "pick attention [hyprpilot]",
          mode = { "n" },
        },

        -- multi-instance
        {
          fn.wk_keystroke({ categories.SIDEKICK, "C" }),
          function()
            require("hyprpilot.palettes.profiles").open()
          end,
          desc = "spawn instance [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "N" }),
          function()
            require("hyprpilot.rpc.instances").fork()
          end,
          desc = "fork current session [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "s" }),
          function()
            require("hyprpilot.palettes.sessions").open()
          end,
          desc = "pick session [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "S" }),
          function()
            require("hyprpilot.palettes.sessions").open_with()
          end,
          desc = "pick session with profile [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "R" }),
          function()
            require("hyprpilot.rpc.instances").restart()
          end,
          desc = "restart current [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "d" }),
          function()
            require("hyprpilot.rpc.instances").toggle_keep_alive()
          end,
          desc = "toggle keep-alive across nvim quit [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "x" }),
          function()
            require("hyprpilot.chat.window").trim()
          end,
          desc = "trim chat buffer [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "X" }),
          function()
            require("hyprpilot.rpc.instances").shutdown()
          end,
          desc = "shutdown current [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "f" }),
          function()
            require("hyprpilot.palettes.instances").open()
          end,
          desc = "pick instance [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "F" }),
          function()
            require("hyprpilot.palettes.instances").open_attached()
          end,
          desc = "pick attached instance [hyprpilot]",
          mode = { "n" },
        },

        -- composer attachments
        {
          fn.wk_keystroke({ categories.SIDEKICK, "a" }),
          function()
            require("hyprpilot.composer").attach_buffer()
          end,
          desc = "attach current buffer [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "p" }),
          function()
            local path = vim.fn.input("attach file: ", "", "file")
            if path == nil or path == "" then
              return
            end
            require("hyprpilot.composer").attach_file(path)
          end,
          desc = "attach file by path [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "P" }),
          function()
            require("hyprpilot.composer").attach_clipboard()
          end,
          desc = "attach from clipboard [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "A" }),
          function()
            require("hyprpilot.composer").paste_buffer()
          end,
          desc = "paste buffer as code [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "a" }),
          function()
            require("hyprpilot.composer").paste_selection()
          end,
          desc = "paste selection as code [hyprpilot]",
          mode = { "v" },
        },

        {
          fn.wk_keystroke({ categories.SIDEKICK, "m" }),
          group = "adapter [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "m", "m" }),
          function()
            require("hyprpilot.palettes.modes").open()
          end,
          desc = "pick mode [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "m", "a" }),
          function()
            require("hyprpilot.palettes.models").open()
          end,
          desc = "pick model [hyprpilot]",
          mode = { "n" },
        },
        {
          fn.wk_keystroke({ categories.SIDEKICK, "m", "e" }),
          function()
            require("hyprpilot.palettes.effort").open()
          end,
          desc = "pick effort [hyprpilot]",
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
