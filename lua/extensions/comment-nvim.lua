-- https://github.com/numToStr/Comment.nvim
local M = {}

M.name = "numToStr/Comment.nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "numToStr/Comment.nvim",
        keys = {
          { "gc", mode = { "n", "v", "x" } },
          { "gb", mode = { "n", "v", "x" } },
        },
      }
    end,
    setup = function()
      return {
        ---Add a space b/w comment and the line
        ---@type boolean
        padding = true,

        ---Lines to be ignored while comment/uncomment.
        ---Could be a regex string or a function that returns a regex string.
        ---Example: Use '^$' to ignore empty lines
        ---@type string|function
        -- ignore = "^$",

        ---Whether to create basic (operator-pending) and extra mappings for NORMAL/VISUAL mode
        ---@type table
        mappings = {
          ---operator-pending mapping
          ---Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
          basic = true,
          ---Extra mapping
          ---Includes `gco`, `gcO`, `gcA`
          extra = true,
          ---Extended mapping
          ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
          extended = false,
        },

        ---LHS of line and block comment toggle mapping in NORMAL/VISUAL mode
        ---@type table
        toggler = {
          ---line-comment toggle
          line = "gcc",
          ---block-comment toggle
          block = "gbc",
        },

        ---LHS of line and block comment operator-mode mapping in NORMAL/VISUAL mode
        ---@type table
        opleader = {
          ---line-comment opfunc mapping
          line = "gc",
          ---block-comment opfunc mapping
          block = "gb",
        },

        ---Pre-hook, called before commenting the line
        ---@type function|nil
        pre_hook = nil,

        ---Post-hook, called after commenting is done
        ---@type function|nil
        post_hook = nil,
      }
    end,
    on_setup = function(c)
      require("Comment").setup(c)
    end,
    on_done = function(config)
      local ft = require("Comment.ft")

      for _, value in pairs(config.comment_strings) do
        ft(value[1], value[2])
      end
    end,
    comment_strings = {
      { { "gomod" }, "//%s" },
      { { "helm" }, "#%s" },
      { { "javascript", "typescript" }, { "//%s", "/**%s*/" } },
      { { "hurl" }, "#%s" },
    },
    -- keymaps = {
    --   normal_mode = {
    --     ["<C-\\>"] = "<CMD>lua require('Comment.api').call('gcc')<CR>g@$",
    --     ["<C-#>"] = "<CMD>lua require('Comment.api').call('gcc')<CR>g@$",
    --     ["<M-#>"] = "<CMD>lua require('Comment.api').call('gbc')<CR>g@$",
    --   },
    --
    --   visual_mode = {
    --     ["<C-\\>"] = "<ESC><CMD>lua require('Comment.api').gc(vim.fn.visualmode())<CR>",
    --     ["<C-#>"] = "<ESC><CMD>lua require('Comment.api').gc(vim.fn.visualmode())<CR>",
    --     ["<M-#>"] = "<ESC><CMD>lua require('Comment.api').gb(vim.fn.visualmode())<CR>",
    --   },
    -- },
  })
end

return M
