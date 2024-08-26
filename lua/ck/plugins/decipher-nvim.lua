-- https://github.com/MisanthropicBit/decipher.nvim
local M = {}

M.name = "MisanthropicBit/decipher.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "MisanthropicBit/decipher.nvim",
      }
    end,
    setup = function()
      ---@type decipher.Config
      return {
        active_codecs = "all", -- Set all codecs as active and useable
        float = { -- Floating window options
          padding = 0, -- Zero padding (does not apply to title if any)
          -- border = nvim.ui.border,
          mappings = {
            close = "q", -- Key to press to close the floating window
            apply = "a", -- Key to press to apply the encoding/decoding
            jsonpp = "J", -- Key to prettily format contents as json if possbile
            help = "?", -- Toggle help
          },
          title = true, -- Display a title with the codec name
          title_pos = "left", -- Position of the title
          autoclose = true, -- Autoclose floating window if insert
          -- mode is activated or the cursor is moved
          enter = true, -- Automatically enter the floating window if
          -- opened
          options = {}, -- Options to apply to the floating window contents
        },
      }
    end,
    on_setup = function(c)
      require("decipher").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          mode = { "v" },
          {
            fn.wk_keystroke({ categories.TASKS, "d" }),
            group = "decode",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "d", "b" }),
            function()
              require("decipher").decode_selection("base64", { preview = true })
            end,
            desc = "base64",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "d", "B" }),
            function()
              require("decipher").decode_selection("base64-url-safe", { preview = true })
            end,
            desc = "base64-url-safe",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "d", "c" }),
            function()
              require("decipher").decode_selection("crockford", { preview = true })
            end,
            desc = "crockford",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "d", "u" }),
            function()
              require("decipher").decode_selection("url", { preview = true })
            end,
            desc = "url",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "d", "U" }),
            function()
              require("decipher").decode_selection("base64-url", { preview = true })
            end,
            desc = "base64+url",
          },

          {
            fn.wk_keystroke({ categories.TASKS, "D" }),
            group = "encode",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "D", "b" }),
            function()
              require("decipher").encode_selection("base64", { preview = true })
            end,
            desc = "base64",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "D", "B" }),
            function()
              require("decipher").encode_selection("base64-url-safe", { preview = true })
            end,
            desc = "base64-url-safe",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "D", "c" }),
            function()
              require("decipher").encode_selection("crockford", { preview = true })
            end,
            desc = "crockford",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "D", "u" }),
            function()
              require("decipher").encode_selection("url", { preview = true })
            end,
            desc = "url",
          },
          {
            fn.wk_keystroke({ categories.TASKS, "D", "U" }),
            function()
              require("decipher").encode_selection("base64-url", { preview = true })
            end,
            desc = "base64+url",
          },
        },
      }
    end,
  })
end

return M
