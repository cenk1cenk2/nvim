-- https://github.com/johmsalas/text-case.nvim
local M = {}

local extension_name = "text_case_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "johmsalas/text-case.nvim",
        cmd = { "Subs" },
        -- keys = { { "gs", mode = { "n", "v", "x" }, desc = "text case [lazy]" } },
      }
    end,
    -- setup = {
    --   prefix = "gs",
    -- },
    -- on_setup = function(config)
    -- subs command comes from here!
    -- require("textcase").setup(config.setup)
    -- end,
    keymaps = {
      {
        { "v" },

        ["gsu"] = {
          function()
            return require("textcase").operator("to_upper_case")
          end,
          { desc = "to upper case" },
        },

        ["gsl"] = {
          function()
            return require("textcase").operator("to_lower_case")
          end,
          { desc = "to lower case" },
        },

        ["gss"] = {
          function()
            return require("textcase").operator("to_snake_case")
          end,
          { desc = "to snake case" },
        },

        ["gsd"] = {
          function()
            return require("textcase").operator("to_dash_case")
          end,
          { desc = "to dash case" },
        },

        ["gsC"] = {
          function()
            return require("textcase").operator("to_constant_case")
          end,
          { desc = "to constant case" },
        },

        ["gsP"] = {
          function()
            return require("textcase").operator("to_phrase_case")
          end,
          { desc = "to phrase case" },
        },

        ["gsc"] = {
          function()
            return require("textcase").operator("to_camel_case")
          end,
          { desc = "to camel case" },
        },

        ["gsp"] = {
          function()
            return require("textcase").operator("to_pascal_case")
          end,
          { desc = "to pascal case" },
        },

        ["gst"] = {
          function()
            return require("textcase").operator("to_title_case")
          end,
          { desc = "to title case" },
        },

        ["gsD"] = {
          function()
            return require("textcase").operator("to_path_case")
          end,
          { desc = "to path case" },
        },
      },
    },
  })
end

return M
