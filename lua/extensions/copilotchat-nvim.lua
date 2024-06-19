-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
local M = {}

local extension_name = "CopilotC-Nvim/CopilotChat.nvim"
local Log = require("lvim.core.log")

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
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
      })
    end,
    setup = function()
      return {
        -- default mappings
        mappings = {
          complete = {
            detail = "Use @<Tab> or /<Tab> for options.",
            insert = "<Tab>",
          },
          close = {
            normal = "q",
            insert = "<C-c>",
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
    on_setup = function(config)
      require("CopilotChat").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        {
          { "n" },

          [categories.COPILOT] = {
            ["a"] = {
              function()
                vim.ui.input({
                  prompt = "ask chatgpt:",
                }, function(question)
                  if question == nil then
                    Log:warn("Nothing to do.")

                    return
                  end

                  require("CopilotChat").ask(question, {
                    selection = require("CopilotChat.select").buffer,
                  })
                end)
              end,
              "ask",
            },

            ["c"] = {
              function()
                require("CopilotChat").toggle()
              end,
              "toggle copilot chat",
            },

            ["p"] = {
              function()
                local actions = require("CopilotChat.actions")
                actions.pick(actions.prompt_actions({
                  selection = require("CopilotChat.select").buffer,
                }))
              end,
              "prompt",
            },

            ["r"] = {
              function()
                require("CopilotChat").reset()
              end,
              "reset chat",
            },

            ["h"] = {
              function()
                local actions = require("CopilotChat.actions")
                actions.pick(actions.help_actions({
                  selection = require("CopilotChat.select").buffer,
                }))
              end,
              "help",
            },
          },
        },

        {
          { "v" },

          [categories.COPILOT] = {
            ["a"] = {
              function()
                vim.ui.input({
                  prompt = "ask chatgpt:",
                }, function(question)
                  if question == nil then
                    Log:warn("Nothing to do.")

                    return
                  end

                  require("CopilotChat").ask(question, {
                    selection = require("CopilotChat.select").visual,
                  })
                end)
              end,
              "ask selection",
            },

            ["c"] = {
              function()
                require("CopilotChat").toggle({
                  selection = require("CopilotChat.select").visual,
                })
              end,
              "toggle copilot chat",
            },

            ["p"] = {
              function()
                local actions = require("CopilotChat.actions")
                actions.pick(actions.prompt_actions({
                  selection = require("CopilotChat.select").visual,
                }))
              end,
              "prompt selection",
            },

            ["h"] = {
              function()
                local actions = require("CopilotChat.actions")
                actions.pick(actions.help_actions({
                  selection = require("CopilotChat.select").visual,
                }))
              end,
              "help selection",
            },
          },
        },
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__copilot",
          pattern = "copilot-chat",
          callback = function()
            require("utils").set_view_buffer()
          end,
        },
      },
    },
  })
end

return M
