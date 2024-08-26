-- https://github.com/johmsalas/text-case.nvim
local M = {}

M.name = "johmsalas/text-case.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "johmsalas/text-case.nvim",
        cmd = { "Subs" },
        -- keys = { { "gs", mode = { "n", "v", "x" }, desc = "text case [lazy]" } },
      }
    end,
    -- setup = {
    --   prefix = "gs",
    -- },
    -- on_setup = function(c)
    -- subs command comes from here!
    -- require("textcase").setup(c)
    -- end,
    keymaps = function()
      return {
        -- subs
        {
          "gsr",
          ":Subs/",
          desc = "SUBS",
          mode = { "n", "v", "x" },
        },
        -- operator
        {
          "gsu",
          function()
            return require("textcase").operator("to_upper_case")
          end,
          desc = "to upper case [LOREM IPSUM]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsl",
          function()
            return require("textcase").operator("to_lower_case")
          end,
          desc = "to lower case [lorem ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gss",
          function()
            return require("textcase").operator("to_snake_case")
          end,
          desc = "to snake case [lorem_ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsd",
          function()
            return require("textcase").operator("to_dash_case")
          end,
          desc = "to dash case [lorem-ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsT",
          function()
            return require("textcase").operator("to_title_dash_case")
          end,
          desc = "to title dash case  [Lorem-Ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsC",
          function()
            return require("textcase").operator("to_constant_case")
          end,
          desc = "to constant case [LOREM_IPSUM]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsD",
          function()
            return require("textcase").operator("to_dot_case")
          end,
          desc = "to dot case [lorem.ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsc",
          function()
            return require("textcase").operator("to_camel_case")
          end,
          desc = "to camel case [loremIpsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsp",
          function()
            return require("textcase").operator("to_pascal_case")
          end,
          desc = "to pascal case [LoremIpsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gst",
          function()
            return require("textcase").operator("to_title_case")
          end,
          desc = "to title case [Lorem Ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsf",
          function()
            return require("textcase").operator("to_path_case")
          end,
          desc = "to path case [lorem/ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gsP",
          function()
            return require("textcase").operator("to_phrase_case")
          end,
          desc = "to phrase case [Lorem ipsum]",
          mode = { "n", "v", "x", "o" },
        },

        -- lsp

        {
          "gSu",
          function()
            return require("textcase").lsp_rename("to_upper_case")
          end,
          desc = "to upper case [LOREM IPSUM]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSl",
          function()
            return require("textcase").lsp_rename("to_lower_case")
          end,
          desc = "to lower case [lorem ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSs",
          function()
            return require("textcase").lsp_rename("to_snake_case")
          end,
          desc = "to snake case [lorem_ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSd",
          function()
            return require("textcase").lsp_rename("to_dash_case")
          end,
          desc = "to dash case [lorem-ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gST",
          function()
            return require("textcase").lsp_rename("to_title_dash_case")
          end,
          desc = "to title dash case [Lorem-Ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSC",
          function()
            return require("textcase").lsp_rename("to_constant_case")
          end,
          desc = "to constant case [LOREM_IPSUM]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSD",
          function()
            return require("textcase").lsp_rename("to_dot_case")
          end,
          desc = "to dot case [lorem.ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSc",
          function()
            return require("textcase").lsp_rename("to_camel_case")
          end,
          desc = "to camel case [loremIpsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSp",
          function()
            return require("textcase").lsp_rename("to_pascal_case")
          end,
          desc = "to pascal case [LoremIpsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSt",
          function()
            return require("textcase").lsp_rename("to_title_case")
          end,
          desc = "to title case [Lorem Ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSf",
          function()
            return require("textcase").lsp_rename("to_path_case")
          end,
          desc = "to path case [lorem/ipsum]",
          mode = { "n", "v", "x", "o" },
        },
        {
          "gSP",
          function()
            return require("textcase").lsp_rename("to_phrase_case")
          end,
          desc = "to phrase case [Lorem ipsum]",
          mode = { "n", "v", "x", "o" },
        },
      }
    end,
  })
end

return M
