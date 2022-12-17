-- https://github.com/jackmort/chatgpt.nvim
local M = {}

local extension_name = "chatgpt_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "jackmort/chatgpt.nvim",
        config = function()
          require("utils.setup").packer_config "chatgpt_nvim"
        end,
        disable = not config.active,
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
          style = "single",
        },
      },
      chat_input = {
        border = {
          style = "single",
        },
        win_options = {
          winhighlight = "Normal:Normal",
        },
      },
      keymaps = {
        close = "<ESC>",
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
          ["a"] = { ":ChatGPT<CR>", "run chatgpt ai" },
        },
      }
    end,
  })
end

return M