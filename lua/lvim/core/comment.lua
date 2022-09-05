local M = {}

function M.config()
  local pre_hook = nil
  if lvim.builtin.treesitter.context_commentstring.enable then
    pre_hook = function(ctx)
      if
        vim.tbl_contains({ "javascript", "typescriptreact", "vue", "svelte" }, function(type)
          return type ~= vim.bo.filetype
        end)
      then
        return
      end

      local U = require "Comment.utils"

      -- Determine whether to use linewise or blockwise commentstring
      local type = ctx.ctype == U.ctype.linewise and "__default" or "__multiline"

      -- Determine the location where to calculate commentstring from
      local location = nil
      if ctx.ctype == U.ctype.blockwise then
        location = require("ts_context_commentstring.utils").get_cursor_location()
      elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
        location = require("ts_context_commentstring.utils").get_visual_start_location()
      end

      return require("ts_context_commentstring.internal").calculate_commentstring {
        key = type,
        location = location,
      }
    end
  end
  lvim.builtin.comment = {
    active = true,
    on_config_done = nil,
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
    pre_hook = pre_hook,

    ---Post-hook, called after commenting is done
    ---@type function|nil
    post_hook = nil,
  }
end

function M.setup()
  local nvim_comment = require "Comment"

  require("lvim.keymappings").load {
    normal_mode = {
      ["<C-\\>"] = "<CMD>lua require('Comment.api').call('gcc')<CR>g@$",
      ["<C-#>"] = "<CMD>lua require('Comment.api').call('gcc')<CR>g@$",
      ["<M-#>"] = "<CMD>lua require('Comment.api').call('gbc')<CR>g@$",
    },

    visual_mode = {
      ["<C-\\>"] = "<ESC><CMD>lua require('Comment.api').gc(vim.fn.visualmode())<CR>",
      ["<C-#>"] = "<ESC><CMD>lua require('Comment.api').gc(vim.fn.visualmode())<CR>",
      ["<M-#>"] = "<ESC><CMD>lua require('Comment.api').gb(vim.fn.visualmode())<CR>",
    },
  }

  nvim_comment.setup(lvim.builtin.comment)
  if lvim.builtin.comment.on_config_done then
    lvim.builtin.comment.on_config_done(nvim_comment)
  end
end

return M
