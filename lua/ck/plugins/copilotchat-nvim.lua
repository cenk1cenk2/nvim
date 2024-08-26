-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
local M = {}

M.name = "CopilotC-Nvim/CopilotChat.nvim"
local log = require("ck.log")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
          { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
          { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        cmd = {
          "CopilotChat",
          "CopilotChatOpen",
          "CopilotChatClose",
          "CopilotChatToggle",
          "CopilotChatReset",
          "CopilotChatSave",
          "CopilotChatLoad",
          "CopilotChatDebugInfo",
          "CopilotChatExplain",
          "CopilotChatTests",
          "CopilotChatFix",
          "CopilotChatOptimize",
          "CopilotChatDocs",
          "CopilotChatFixDiagnostic",
          "CopilotChatCommit",
          "CopilotChatCommitStaged",
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "copilot-chat",
        "copilot-diff",
        "copilot-system-prompt",
        "copliot-user-selection",
      })
    end,
    setup = function()
      ---@type CopilotChat.config
      return {
        -- default mappings
        show_help = false,
        show_folds = false,
        clear_chat_on_new_prompt = false,
        context = "buffer",
        mappings = {
          -- complete = {
          --   detail = "Use @<Tab> or /<Tab> for options.",
          --   insert = "<Tab>",
          -- },
          complete = {
            insert = "",
          },
          close = {
            normal = "q",
            insert = "",
            -- insert = "<C-c>",
          },
          reset = {
            normal = "<m-l>",
            insert = "<m-l>",
          },
          submit_prompt = {
            normal = "<CR>",
            insert = "<m-m>",
          },
          accept_diff = {
            normal = "<m-y>",
            insert = "<m-y>",
          },
          yank_diff = {
            normal = "gy",
          },
          show_diff = {
            normal = "gd",
          },
          show_system_prompt = {
            normal = "gp",
          },
          show_user_selection = {
            normal = "gs",
          },
        },
      }
    end,
    on_setup = function(c)
      if is_enabled(get_plugin_name("cmp")) then
        require("CopilotChat.integrations.cmp").setup()
      end
      require("CopilotChat").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.COPILOT, "a" }),
          function()
            vim.ui.input({
              prompt = "ask chatgpt:",
            }, function(question)
              if question == nil then
                log:warn("Nothing to do.")

                return
              end

              require("CopilotChat").ask(question, {
                selection = require("CopilotChat.select").buffer,
              })
            end)
          end,
          desc = "ask",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "c" }),
          function()
            require("CopilotChat").toggle()
          end,
          desc = "toggle copilot chat",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "p" }),
          function()
            local actions = require("CopilotChat.actions")
            actions.pick(actions.prompt_actions({
              selection = require("CopilotChat.select").buffer,
            }))
          end,
          desc = "prompt",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "r" }),
          function()
            require("CopilotChat").reset()
          end,
          desc = "reset chat",
        },
        {
          fn.wk_keystroke({ categories.COPILOT, "h" }),
          function()
            local actions = require("CopilotChat.actions")
            actions.pick(actions.help_actions({
              selection = require("CopilotChat.select").buffer,
            }))
          end,
          desc = "help",
        },
        {
          mode = { "v" },
          {
            fn.wk_keystroke({ categories.COPILOT, "a" }),
            function()
              vim.ui.input({
                prompt = "ask chatgpt:",
              }, function(question)
                if question == nil then
                  log:warn("Nothing to do.")

                  return
                end

                require("CopilotChat").ask(question, {
                  selection = require("CopilotChat.select").visual,
                })
              end)
            end,
            desc = "ask selection",
          },
          {
            fn.wk_keystroke({ categories.COPILOT, "c" }),
            function()
              require("CopilotChat").toggle({
                selection = require("CopilotChat.select").visual,
              })
            end,
            desc = "toggle copilot chat",
          },
          {
            fn.wk_keystroke({ categories.COPILOT, "p" }),
            function()
              local actions = require("CopilotChat.actions")
              actions.pick(actions.prompt_actions({
                selection = require("CopilotChat.select").visual,
              }))
            end,
            desc = "prompt selection",
          },
          {
            fn.wk_keystroke({ categories.COPILOT, "h" }),
            function()
              local actions = require("CopilotChat.actions")
              actions.pick(actions.help_actions({
                selection = require("CopilotChat.select").visual,
              }))
            end,
            desc = "help selection",
          },
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").set_view_buffer({
          "copilot-chat",
          "copilot-diff",
          "copilot-system-prompt",
          "copliot-user-selection",
        }),
      }
    end,
  })
end

return M
