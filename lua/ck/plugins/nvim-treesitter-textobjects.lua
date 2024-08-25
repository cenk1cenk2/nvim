-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local M = {}

M.name = "nvim-treesitter/nvim-treesitter-textobjects"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "BufReadPost",
      }
    end,
    setup = function(_, fn)
      local a = "b"
      -- builtin textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects?tab=readme-ov-file#built-in-textobjects
      return {
        textobjects = {
          swap = {
            enable = false,
            swap_previous = {
              ["H"] = { query = { "@field", "@pair", "@array", "@element", "@parameter.inner" }, desc = "" },
            },
            swap_next = {
              ["L"] = { query = { "@field", "@pair", "@array", "@element", "@parameter.inner" }, desc = "" },
            },
          },
          lsp_interop = {
            enable = true,
            border = "rounded",
            floating_preview_opts = {},
            peek_definition_code = {
              ["gwc"] = { query = "@class.outer", desc = "Peek class", silent = true },
              ["gwm"] = { query = "@function.outer", desc = "Peek function", silent = true },
              ["gwa"] = { query = "@assignment.outer", desc = "Peek assignment", silent = true },
            },
          },
          select = {
            enable = true,
            lookahead = false,
            keymaps = {
              -- ["ia"] = { query = "@parameter.inner", desc = "select inner part of a parameter/argument" },
              -- ["aa"] = { query = "@parameter.outer", desc = "select outer part of a parameter/argument" },
              ["im"] = { query = "@function.inner", desc = "select inner part of a method" },
              ["am"] = { query = "@function.outer", desc = "select outer part of a method" },
              ["ic"] = { query = "@class.inner", desc = "select inner part of a class region" },
              ["ac"] = { query = "@class.outer", desc = "select outer part of a class region" },
              ["iv"] = { query = "@assignment.rhs", desc = "select rhs of assignment" },
              ["av"] = { query = "@assignment.lhs", desc = "select lfs of assignment" },
              ["if"] = { query = "@call.inner", desc = "select inner part of the call" },
              ["af"] = { query = "@call.outer", desc = "select outer part of the call" },
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.inner"] = "V",
              ["@function.outer"] = "v",
              ["@class.outer"] = "v",
            },
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = { query = "@function.outer", des = "jump to next method start" },
              ["]c"] = { query = "@class.outer", desc = "jump to next class start" },
              ["]s"] = { query = "@scope", query_group = "locals", desc = "jump to next scope start" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "jump to next fold start" },
              ["]a"] = { query = "@parameter.inner", desc = "jump to next parameter start" },
              ["]p"] = { query = "@attribute.inner", desc = "jump to next attribute start" },
            },
            goto_previous_start = {
              ["[m"] = { query = "@function.outer", des = "jump to previous method start" },
              ["[c"] = { query = "@class.outer", desc = "jump to previous class start" },
              ["[s"] = { query = "@scope", query_group = "locals", desc = "jump to previous scope start" },
              ["[Z"] = { query = "@fold", query_group = "folds", desc = "jump to previous fold start" },
              ["[a"] = { query = "@parameter.inner", desc = "jump to previous parameter start" },
              ["[p"] = { query = "@attribute.inner", desc = "jump to previous attribute start" },
            },
            goto_next_end = {
              ["]M"] = { query = "@function.outer", des = "jump to next method end" },
              ["]C"] = { query = "@class.outer", desc = "jump to next class end" },
              ["]S"] = { query = "@scope", query_group = "locals", desc = "jump to next scope end" },
              ["]A"] = { query = "@parameter.inner", desc = "jump to next parameter start" },
            },
            goto_previous_end = {
              ["[M"] = { query = "@function.outer", des = "jump to previous method end" },
              ["[C"] = { query = "@class.outer", desc = "jump to previous class end" },
              ["[S"] = { query = "@scope", query_group = "locals", desc = "jump to previous scope end" },
              ["[A"] = { query = "@parameter.inner", desc = "jump to next parameter start" },
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {},
            goto_previous = {},
          },
        },
      }
    end,
    on_setup = function(c)
      require("nvim-treesitter.configs").setup(c)
    end,
  })
end

return M
