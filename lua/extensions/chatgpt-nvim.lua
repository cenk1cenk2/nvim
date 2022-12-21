-- https://github.com/jackmort/chatgpt.nvim
local M = {}

local extension_name = "chatgpt_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "jackmort/chatgpt.nvim",
        cmd = { "ChatGPT", "ChatGPTEditWithInstructions" },
        enabled = config.active,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes {
        "chatgpt",
      }
    end,
    setup = {
      welcome_message = "",
      yank_register = "+",
      openai_params = {
        model = "text-davinci-003",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 300,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
      chat_window = {
        border = {
          style = lvim.ui.border,
        },
      },
      chat_input = {
        border = {
          style = lvim.ui.border,
        },
        win_options = {
          winhighlight = "Normal:Normal",
        },
      },
      keymaps = {
        close = "<C-c>",
        yank_last = "<C-y>",
        scroll_up = "<C-u>",
        scroll_down = "<C-d>",
      },
    },
    on_setup = function(config)
      require("chatgpt").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["a"] = { ":ChatGPT<CR>", "run chatgpt-ai" },
          ["A"] = { ":ChatGPTEditWithInstructions<CR>", "edit code with chatgpt-ai" },
        },
      }
    end,
  })
end

return M
