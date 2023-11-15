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
        { "v", "vb", "o", "n" },

        -- subs

        ["gsr"] = {
          ":Subs ",
          { desc = "SUBS" },
        },

        -- operator

        ["gsu"] = {
          function()
            return require("textcase").operator("to_upper_case")
          end,
          { desc = "to upper case [LOREM IPSUM]" },
        },

        ["gsl"] = {
          function()
            return require("textcase").operator("to_lower_case")
          end,
          { desc = "to lower case [lorem ipsum]" },
        },

        ["gss"] = {
          function()
            return require("textcase").operator("to_snake_case")
          end,
          { desc = "to snake case [lorem_ipsum]" },
        },

        ["gsd"] = {
          function()
            return require("textcase").operator("to_dash_case")
          end,
          { desc = "to dash case [lorem-ipsum]" },
        },

        ["gsT"] = {
          function()
            return require("textcase").operator("to_title_dash_case")
          end,
          { desc = "to title dash case  [Lorem-Ipsum]" },
        },

        ["gsC"] = {
          function()
            return require("textcase").operator("to_constant_case")
          end,
          { desc = "to constant case [LOREM_IPSUM]" },
        },

        ["gsD"] = {
          function()
            return require("textcase").operator("to_dot_case")
          end,
          { desc = "to dot case [lorem.ipsum]" },
        },

        ["gsc"] = {
          function()
            return require("textcase").operator("to_camel_case")
          end,
          { desc = "to camel case [loremIpsum]" },
        },

        ["gsp"] = {
          function()
            return require("textcase").operator("to_pascal_case")
          end,
          { desc = "to pascal case [LoremIpsum]" },
        },

        ["gst"] = {
          function()
            return require("textcase").operator("to_title_case")
          end,
          { desc = "to title case [Lorem Ipsum]" },
        },

        ["gsf"] = {
          function()
            return require("textcase").operator("to_path_case")
          end,
          { desc = "to path case [lorem/ipsum]" },
        },

        ["gsP"] = {
          function()
            return require("textcase").operator("to_phrase_case")
          end,
          { desc = "to phrase case [Lorem ipsum]" },
        },

        -- lsp

        ["gSu"] = {
          function()
            return require("textcase").lsp_rename("to_upper_case")
          end,
          { desc = "to upper case [LOREM IPSUM]" },
        },

        ["gSl"] = {
          function()
            return require("textcase").lsp_rename("to_lower_case")
          end,
          { desc = "to lower case [lorem ipsum]" },
        },

        ["gSs"] = {
          function()
            return require("textcase").lsp_rename("to_snake_case")
          end,
          { desc = "to snake case [lorem_ipsum]" },
        },

        ["gSd"] = {
          function()
            return require("textcase").lsp_rename("to_dash_case")
          end,
          { desc = "to dash case [lorem-ipsum]" },
        },

        ["gST"] = {
          function()
            return require("textcase").lsp_rename("to_title_dash_case")
          end,
          { desc = "to title dash case [Lorem-Ipsum]" },
        },

        ["gSC"] = {
          function()
            return require("textcase").lsp_rename("to_constant_case")
          end,
          { desc = "to constant case [LOREM_IPSUM]" },
        },

        ["gSD"] = {
          function()
            return require("textcase").lsp_rename("to_dot_case")
          end,
          { desc = "to dot case [lorem.ipsum]" },
        },

        ["gSc"] = {
          function()
            return require("textcase").lsp_rename("to_camel_case")
          end,
          { desc = "to camel case [loremIpsum]" },
        },

        ["gSp"] = {
          function()
            return require("textcase").lsp_rename("to_pascal_case")
          end,
          { desc = "to pascal case [LoremIpsum]" },
        },

        ["gSt"] = {
          function()
            return require("textcase").lsp_rename("to_title_case")
          end,
          { desc = "to title case [Lorem Ipsum]" },
        },

        ["gSf"] = {
          function()
            return require("textcase").lsp_rename("to_path_case")
          end,
          { desc = "to path case [lorem/ipsum]" },
        },

        ["gSP"] = {
          function()
            return require("textcase").lsp_rename("to_phrase_case")
          end,
          { desc = "to phrase case [Lorem ipsum]" },
        },
      },
    },
  })
end

return M
