-- https://github.com/kylechui/nvim-surround

local M = {}

M.name = "kylechui/nvim-surround"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      vim.g.nvim_surround_no_mappings = true
      ---@type Plugin
      return {
        "kylechui/nvim-surround",
        event = { "BufReadPost", "BufNewFile", "BufNew" },
      }
    end,
    setup = function()
      ---@type user_options
      return {
        aliases = {
          ["t"] = ">",
          ["p"] = ")",
          ["c"] = "}",
          ["a"] = "]",
          ["q"] = { '"', "'", "`" },
          ["b"] = { "}", "]", ")" },
          ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
        },
      }
    end,
    on_setup = function(c)
      require("nvim-surround").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        -- { "<C-g>s", "<Plug>(nvim-surround-insert)", desc = "surround insert", mode = { "i" } },
        -- { "<C-g>S", "<Plug>(nvim-surround-insert-line)", desc = "surround insert line", mode = { "i" } },
        -- { "ys", "<Plug>(nvim-surround-normal)", desc = "surround", mode = { "n" } },
        -- { "yss", "<Plug>(nvim-surround-normal-cur)", desc = "surround line", mode = { "n" } },
        -- { "yS", "<Plug>(nvim-surround-normal-line)", desc = "surround on new lines", mode = { "n" } },
        -- { "ySS", "<Plug>(nvim-surround-normal-cur-line)", desc = "surround line on new lines", mode = { "n" } },
        { "s", "<Plug>(nvim-surround-visual)", desc = "surround visual", mode = { "v" } },
        -- { "gS", "<Plug>(nvim-surround-visual-line)", desc = "surround visual line", mode = { "v" } },
        { "ds", "<Plug>(nvim-surround-delete)", desc = "surround delete", mode = { "n" } },
        { "cs", "<Plug>(nvim-surround-change)", desc = "surround change", mode = { "n" } },
      }
    end,
  })
end

return M
