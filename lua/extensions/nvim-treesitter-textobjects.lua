-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
local M = {}

local extension_name = "nvim_treesitter_textobjects"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        event = "BufReadPost",
      }
    end,
    setup = function()
      return {
        textobjects = {
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
              ["as"] = { query = "@scope", query_group = "locals", desc = "select language scope" },
              ["is"] = { query = "@scope.inner", query_group = "locals", desc = "select language scope" },
            },
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.inner"] = "V",
              ["@function.outer"] = "v",
              ["@class.outer"] = "v",
            },
            include_surrounding_whitespace = false,
          },
          swap = {
            enable = true,
            swap_previous = {
              ["HH"] = { query = { "@parameter.inner", "@element" }, desc = "" },
            },
            swap_next = {
              ["LL"] = { query = { "@parameter.inner", "@element" }, desc = "" },
            },
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
            },
            goto_previous_start = {
              ["[m"] = { query = "@function.outer", des = "jump to previous method start" },
              ["[c"] = { query = "@class.outer", desc = "jump to previous class start" },
              ["[s"] = { query = "@scope", query_group = "locals", desc = "jump to previous scope start" },
              ["[a"] = { query = "@parameter.inner", desc = "jump to previous parameter start" },
            },
            goto_next_end = {
              ["]M"] = { query = "@function.outer", des = "jump to next method end" },
              ["]C"] = { query = "@class.outer", desc = "jump to next class end" },
              ["]S"] = { query = "@scope", query_group = "locals", desc = "jump to next scope end" },
              ["[Z"] = { query = "@fold", query_group = "folds", desc = "jump to next fold start" },
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
    on_setup = function(config)
      require("nvim-treesitter.configs").setup(config.setup)
    end,
  })
end

return M
