-- https://github.com/MisanthropicBit/decipher.nvim
local M = {}

local extension_name = "MisanthropicBit/decipher.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "MisanthropicBit/decipher.nvim",
      }
    end,
    setup = function()
      return {
        active_codecs = "all", -- Set all codecs as active and useable
        float = { -- Floating window options
          padding = 2, -- Zero padding (does not apply to title if any)
          -- border = lvim.ui.border,
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
    on_setup = function(config)
      require("decipher").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        {
          { "v" },

          [categories.TASKS] = {
            ["d"] = {
              name = "decode",

              ["b"] = {
                function()
                  require("decipher").decode_selection("base64", { preview = true })
                end,
                "base64",
              },

              ["B"] = {
                function()
                  require("decipher").decode_selection("base64-url-safe", { preview = true })
                end,
                "base64-url-safe",
              },

              ["c"] = {
                function()
                  require("decipher").decode_selection("crockford", { preview = true })
                end,
                "crockford",
              },

              ["u"] = {
                function()
                  require("decipher").decode_selection("url", { preview = true })
                end,
                "url",
              },

              ["U"] = {
                function()
                  require("decipher").decode_selection("base64-url", { preview = true })
                end,
                "base64+url",
              },
            },
            ["D"] = {
              name = "encode",

              ["b"] = {
                function()
                  require("decipher").encode_selection("base64", { preview = true })
                end,
                "base64",
              },

              ["B"] = {
                function()
                  require("decipher").encode_selection("base64-url-safe", { preview = true })
                end,
                "base64-url-safe",
              },

              ["c"] = {
                function()
                  require("decipher").encode_selection("crockford", { preview = true })
                end,
                "crockford",
              },

              ["u"] = {
                function()
                  require("decipher").encode_selection("url", { preview = true })
                end,
                "url",
              },

              ["U"] = {
                function()
                  require("decipher").encode_selection("base64-url", { preview = true })
                end,
                "base64+url",
              },
            },
          },
        },
      }
    end,
  })
end

return M
