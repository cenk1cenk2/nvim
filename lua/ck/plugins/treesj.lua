-- https://github.com/Wansmer/treesj
local M = {}

M.name = "Wansmer/treesj"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      return {
        use_default_keymaps = false,
        check_syntax_error = true,
        max_join_length = math.huge,
        cursor_behavior = "hold",
        notify = true,
        dot_repeat = true,
      }
    end,
    on_setup = function(c)
      require("treesj").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "gJ",
          function()
            require("treesj").join()
          end,
          desc = "treesitter join lines",
          mode = { "n", "v" },
        },
        {
          "gK",
          function()
            require("treesj").split()
          end,
          desc = "treesitter split lines",
          mode = { "n", "v" },
        },
      }
    end,
  })
end

return M
