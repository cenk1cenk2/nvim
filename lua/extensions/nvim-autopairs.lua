-- https://github.com/windwp/nvim-autopairs

local M = {}

local extension_name = "nvim_autopairs"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "windwp/nvim-autopairs",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
      }
    end,
    setup = {
      ---@usage  modifies the function or method delimiter by filetypes
      map_char = {
        all = "(",
        tex = "{",
      },
      ---@usage check bracket in same line
      enable_check_bracket_line = false,
      ---@usage check treesitter
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = lvim.disabled_filetypes,
      ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
      enable_moveright = true,
      ---@usage disable when recording or executing a macro
      disable_in_macro = false,
      ---@usage add bracket pairs after quote
      enable_afterquote = true,
      ---@usage map the <BS> key
      map_bs = true,
      ---@usage map <c-w> to delete a pair if possible
      map_c_w = false,
      ---@usage disable when insert after visual block mode
      disable_in_visualblock = false,
      ---@usage  change default fast_wrap
      fast_wrap = {
        map = "<M-w>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = lvim.selection_chars,
        check_comma = true,
        highlight = "AutoPairsFastWrap",
        highlight_grey = "",
      },
    },
    on_setup = function(config)
      require("nvim-autopairs").setup(config.setup)
    end,
    on_done = function()
      require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })

      pcall(function()
        require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end)
    end,
  })
end

return M
