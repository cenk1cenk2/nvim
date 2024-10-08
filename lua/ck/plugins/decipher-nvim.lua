-- https://github.com/MisanthropicBit/decipher.nvim
local M = {}

M.name = "MisanthropicBit/decipher.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "MisanthropicBit/decipher.nvim",
      }
    end,
    setup = function(_, fn)
      ---@type decipher.Config
      return {
        active_codecs = "all", -- Set all codecs as active and useable
        float = { -- Floating window options
          padding = 0, -- Zero padding (does not apply to title if any)
          -- border = nvim.ui.border,
          mappings = {
            close = "q", -- Key to press to close the floating window
            apply = fn.local_keystroke({ "a" }), -- Key to press to apply the encoding/decoding
            jsonpp = fn.local_keystroke({ "J" }), -- Key to prettily format contents as json if possbile
            help = "g?", -- Toggle help
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
    keymaps = function(_, fn)
      return {
        {
          fn.keystroke({ "g", "z" }),
          function()
            require("decipher").decode_motion_prompt({ preview = true })
          end,
          desc = "decode",
          mode = { "n", "o", "v" },
        },
        {
          fn.keystroke({ "g", "Z" }),
          function()
            require("decipher").encode_motion_prompt({ preview = true })
          end,
          desc = "encode",
          mode = { "n", "o", "v" },
        },
      }
    end,
  })
end

return M
