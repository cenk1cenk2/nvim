-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local M = {}

M.name = "nvim-treesitter/nvim-treesitter-textobjects"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
        branch = "main", -- Changed from "master" to "main"
      }
    end,
    setup = function()
      ---@type table
      return {
        select = {
          lookahead = false,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.inner"] = "V",
            ["@function.outer"] = "v",
            ["@class.outer"] = "v",
          },
          include_surrounding_whitespace = false,
        },
        move = {
          -- whether to set jumps in the jumplist
          set_jumps = true,
        },
      }
    end,
    on_setup = function(c)
      -- Main branch uses a different setup function
      require("nvim-treesitter-textobjects").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      return {
        -- Select textobjects
        {
          "im",
          function()
            select.select_textobject("@function.inner", "textobjects")
          end,
          desc = "select inner part of a method",
          mode = { "x", "o" },
        },
        {
          "am",
          function()
            select.select_textobject("@function.outer", "textobjects")
          end,
          desc = "select outer part of a method",
          mode = { "x", "o" },
        },
        {
          "ig",
          function()
            select.select_textobject("@local.scope", "locals")
          end,
          desc = "select inner part of the scope",
          mode = { "x", "o" },
        },
        {
          "ic",
          function()
            select.select_textobject("@class.inner", "textobjects")
          end,
          desc = "select inner part of a class region",
          mode = { "x", "o" },
        },
        {
          "ac",
          function()
            select.select_textobject("@class.outer", "textobjects")
          end,
          desc = "select outer part of a class region",
          mode = { "x", "o" },
        },
        {
          "iv",
          function()
            select.select_textobject("@assignment.rhs", "textobjects")
          end,
          desc = "select rhs of assignment",
          mode = { "x", "o" },
        },
        {
          "av",
          function()
            select.select_textobject("@assignment.lhs", "textobjects")
          end,
          desc = "select lhs of assignment",
          mode = { "x", "o" },
        },
        {
          "if",
          function()
            select.select_textobject("@call.inner", "textobjects")
          end,
          desc = "select inner part of the call",
          mode = { "x", "o" },
        },
        {
          "af",
          function()
            select.select_textobject("@call.outer", "textobjects")
          end,
          desc = "select outer part of the call",
          mode = { "x", "o" },
        },

        -- Move to next/previous textobjects
        {
          "]]m",
          function()
            move.goto_next_start("@function.outer", "textobjects")
          end,
          desc = "jump to next method start",
          mode = { "n", "x", "o" },
        },
        {
          "]]c",
          function()
            move.goto_next_start("@class.outer", "textobjects")
          end,
          desc = "jump to next class start",
          mode = { "n", "x", "o" },
        },
        {
          "]]s",
          function()
            move.goto_next_start("@local.scope", "locals")
          end,
          desc = "jump to next scope start",
          mode = { "n", "x", "o" },
        },
        {
          "]]z",
          function()
            move.goto_next_start("@fold", "folds")
          end,
          desc = "jump to next fold start",
          mode = { "n", "x", "o" },
        },
        {
          "]]a",
          function()
            move.goto_next_start("@parameter.inner", "textobjects")
          end,
          desc = "jump to next parameter start",
          mode = { "n", "x", "o" },
        },
        {
          "]]p",
          function()
            move.goto_next_start("@attribute.inner", "textobjects")
          end,
          desc = "jump to next attribute start",
          mode = { "n", "x", "o" },
        },
        {
          "]]v",
          function()
            move.goto_next_start("@assignment.outer", "textobjects")
          end,
          desc = "jump to next assignment start",
          mode = { "n", "x", "o" },
        },
        {
          "[[m",
          function()
            move.goto_previous_start("@function.outer", "textobjects")
          end,
          desc = "jump to previous method start",
          mode = { "n", "x", "o" },
        },
        {
          "[[c",
          function()
            move.goto_previous_start("@class.outer", "textobjects")
          end,
          desc = "jump to previous class start",
          mode = { "n", "x", "o" },
        },
        {
          "[[s",
          function()
            move.goto_previous_start("@local.scope", "locals")
          end,
          desc = "jump to previous scope start",
          mode = { "n", "x", "o" },
        },
        {
          "[[Z",
          function()
            move.goto_previous_start("@fold", "folds")
          end,
          desc = "jump to previous fold start",
          mode = { "n", "x", "o" },
        },
        {
          "[[a",
          function()
            move.goto_previous_start("@parameter.inner", "textobjects")
          end,
          desc = "jump to previous parameter start",
          mode = { "n", "x", "o" },
        },
        {
          "[[p",
          function()
            move.goto_previous_start("@attribute.inner", "textobjects")
          end,
          desc = "jump to previous attribute start",
          mode = { "n", "x", "o" },
        },
        {
          "[[v",
          function()
            move.goto_previous_start("@assignment.outer", "textobjects")
          end,
          desc = "jump to previous assignment start",
          mode = { "n", "x", "o" },
        },
        {
          "[[M",
          function()
            move.goto_previous_end("@function.outer", "textobjects")
          end,
          desc = "jump to previous method end",
          mode = { "n", "x", "o" },
        },
        {
          "[[C",
          function()
            move.goto_previous_end("@class.outer", "textobjects")
          end,
          desc = "jump to previous class end",
          mode = { "n", "x", "o" },
        },
        {
          "[[S",
          function()
            move.goto_previous_end("@local.scope", "locals")
          end,
          desc = "jump to previous scope end",
          mode = { "n", "x", "o" },
        },
        {
          "[[A",
          function()
            move.goto_previous_end("@parameter.inner", "textobjects")
          end,
          desc = "jump to previous parameter end",
          mode = { "n", "x", "o" },
        },
        {
          "]]M",
          function()
            move.goto_next_end("@function.outer", "textobjects")
          end,
          desc = "jump to next method end",
          mode = { "n", "x", "o" },
        },
        {
          "]]C",
          function()
            move.goto_next_end("@class.outer", "textobjects")
          end,
          desc = "jump to next class end",
          mode = { "n", "x", "o" },
        },
        {
          "]]S",
          function()
            move.goto_next_end("@local.scope", "locals")
          end,
          desc = "jump to next scope end",
          mode = { "n", "x", "o" },
        },
        {
          "]]A",
          function()
            move.goto_next_end("@parameter.inner", "textobjects")
          end,
          desc = "jump to next parameter end",
          mode = { "n", "x", "o" },
        },

        -- Swap textobjects (keeping the existing functionality)
        {
          "H",
          function()
            swap.swap_previous("@field")
          end,
          desc = "swap with previous field",
          mode = { "n" },
        },
        {
          "L",
          function()
            swap.swap_next("@field")
          end,
          desc = "swap with next field",
          mode = { "n" },
        },
      }
    end,
  })
end

return M
