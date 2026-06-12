-- https://github.com/folke/sidekick.nvim
local M = {}

local log = require("ck.log")

M.name = "folke/sidekick.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, nvim.lsp.ai.copilot.nes.enabled, {
    plugin = function()
      ---@type Plugin
      return {
        "folke/sidekick.nvim",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        jump = {
          jumplist = true, -- add an entry to the jumplist
        },
        signs = {
          enabled = true, -- enable signs by default
          icon = nvim.ui.icons.misc.Robot,
        },
        cli = {
          watch = true,
          tools = {
            [M.SIDEKICK_TOOL] = {
              cmd = {
                "hyprpilot",
                "spawn",
                "--with-config",
                "@" .. vim.json.encode({
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
                }),
              },
              url = "https://github.com/hyprpilot/hyprpilot",
            },
          },
          win = {
            split = {
              width = 0.4,
            },
            keys = {
              buffers = { "<c-b>", "buffers", mode = "nt", desc = "open buffer picker" },
              files = { "<c-f>", "files", mode = "nt", desc = "open file picker" },
              hide_n = { "q", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_q = { "<c-q>", "hide", mode = "n", desc = "hide the terminal window" },
              hide_ctrl_dot = { "<c-.>", "hide", mode = "nt", desc = "hide the terminal window" },
              hide_ctrl_z = { "<c-z>", "blur", mode = "nt", desc = "go back to the previous window without hiding the terminal" },
              prompt = { "<c-p>", "prompt", mode = "t", desc = "insert prompt or context" },
              stopinsert = { "<c-q>", "stopinsert", mode = "t", desc = "enter normal mode" },
              -- Navigate windows in terminal mode. Only active when:
              -- * layout is not "float"
              -- * there is another window in the direction
              -- With the default layout of "right", only `<c-h>` will be mapped
              nav_left = { "<c-h>", "nav_left", expr = true, desc = "navigate to the left window" },
              nav_down = { "<c-j>", "nav_down", expr = true, desc = "navigate to the below window" },
              nav_up = { "<c-k>", "nav_up", expr = true, desc = "navigate to the above window" },
              nav_right = { "<c-l>", "nav_right", expr = true, desc = "navigate to the right window" },
            },
          },
        },
        nes = {
          ---@type boolean|fun(buf:integer):boolean?
          enabled = function(buf)
            return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false and nvim.lsp.ai.copilot.nes.enabled
          end,
          debounce = nvim.lsp.ai.copilot.nes.debounce,
          trigger = {
            -- events that trigger sidekick next edit suggestions
            events = nvim.lsp.ai.copilot.nes.events.suggest,
          },
          clear = {
            -- events that clear the current next edit suggestion
            events = nvim.lsp.ai.copilot.nes.events.clear,
            esc = true, -- clear next edit suggestions when pressing <Esc>
          },
          ---@class sidekick.diff.Opts
          ---@field inline? "words"|"chars"|false Enable inline diffs
          diff = {
            inline = "words",
            show = "cursor",
          },
        },
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "t" }),
          group = "sidekick",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "t" }),
          function()
            require("sidekick.cli").toggle({ name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "toggle [hyprpilot]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "<Space>" }),
          function()
            require("sidekick.cli").focus({ name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "focus [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "<CR>" }),
          function()
            local cli = require("sidekick.cli")

            cli.prompt(function(_, text)
              if text then
                cli.send({ name = M.SIDEKICK_TOOL, focus = true, text = text })
              end
            end)
          end,
          desc = "pick prompt/context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "f" }),
          function()
            require("sidekick.cli.picker").open("files", { name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "add file context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "b" }),
          function()
            require("sidekick.cli.picker").open("buffers", { name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "add buffer context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "g" }),
          function()
            require("sidekick.cli.picker").open("grep", { name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "add grep context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "d" }),
          function()
            require("sidekick.cli.picker").open("diagnostics", { name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "add diagnostics context [sidekick]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "t", "q" }),
          function()
            require("sidekick.cli.picker").open("qflist", { name = M.SIDEKICK_TOOL, focus = true })
          end,
          desc = "add quickfix context [sidekick]",
          mode = { "n", "v" },
        },
      }
    end,
    on_setup = function(config)
      require("sidekick").setup(config)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<M-d>",
          function()
            require("sidekick").clear()
          end,
          desc = "nes: abort",
          mode = { "i", "n", "v" },
        },
        {
          "<M-s>",
          function()
            require("sidekick.nes").jump()
          end,
          desc = "nes: jump to start",
          mode = { "i", "n", "v" },
        },
        {
          "<M-a>",
          function()
            local applied = require("sidekick.nes").apply()
            if not applied then
              log:info("Requesting NES...")
              require("sidekick.nes").update()
            end
          end,
          desc = "nes: apply",
          mode = { "i", "n", "v" },
        },
        {
          "<M-f>",
          function()
            require("sidekick.nes").update()
          end,
          desc = "nes: request suggestion",
          mode = { "i", "n", "v" },
        },
      }
    end,
  })
end

M.SIDEKICK_TOOL = "hyprpilot"

return M
