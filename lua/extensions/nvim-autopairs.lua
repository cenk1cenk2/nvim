-- https://github.com/windwp/nvim-autopairs

local M = {}

M.name = "windwp/nvim-autopairs"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "windwp/nvim-autopairs",
        dependencies = { "hrsh7th/nvim-cmp" },
        event = "InsertEnter",
      }
    end,
    setup = function()
      return {
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
        enable_moveright = false,
        ---@usage disable when recording or executing a macro
        disable_in_macro = false,
        ---@usage add bracket pairs after quote
        enable_afterquote = true,
        ---@usage map the <BS> key
        map_bs = true,
        ---@usage map <c-w> to delete a pair if possible
        map_c_w = true,
        ---@usage disable when insert after visual block mode
        disable_in_visualblock = false,
        ---@usage  change default fast_wrap
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'", "<" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          offset = 0, -- Offset from pattern match
          end_key = "$",
          keys = lvim.selection_chars,
          check_comma = true,
          highlight = "AutoPairsFastWrap",
          highlight_grey = "",
        },
      }
    end,
    on_setup = function(config)
      require("nvim-autopairs").setup(config.setup)

      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      -- Add spaces between parentheses

      local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
      npairs.add_rules({
        Rule(" ", " "):with_pair(function(opts)
          local pair = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({
            brackets[1][1] .. brackets[1][2],
            brackets[2][1] .. brackets[2][2],
            brackets[3][1] .. brackets[3][2],
          }, pair)
        end),
      })

      for _, bracket in pairs(brackets) do
        npairs.add_rules({
          Rule(bracket[1] .. " ", " " .. bracket[2])
            :with_pair(function()
              return false
            end)
            :with_move(function(opts)
              return opts.prev_char:match(".%" .. bracket[2]) ~= nil
            end)
            :use_key(bracket[2]),
        })
      end

      -- angle brackets
      npairs.add_rules({
        Rule("<", ">"):with_pair(cond.before_regex("%a+")),
      })

      -- arrow key on javascript
      Rule("%(.*%)%s*%=>$", " {  }", { "javascript", "typescript", "javascriptreact", "typescriptreact", "vue", "svelte" }):use_regex(true):set_end_pair_length(2)

      -- auto addspace on =
      Rule("=", "")
        :with_pair(cond.not_inside_quote())
        :with_pair(function(opts)
          local last_char = opts.line:sub(opts.col - 1, opts.col - 1)
          if last_char:match("[%w%=%s]") then
            return true
          end
          return false
        end)
        :replace_endpair(function(opts)
          local prev_2char = opts.line:sub(opts.col - 2, opts.col - 1)
          local next_char = opts.line:sub(opts.col, opts.col)
          next_char = next_char == " " and "" or " "
          if prev_2char:match("%w$") then
            return "<bs> =" .. next_char
          end
          if prev_2char:match("%=$") then
            return next_char
          end
          if prev_2char:match("=") then
            return "<bs><bs>=" .. next_char
          end
          return ""
        end)
        :set_end_pair_length(0)
        :with_move(cond.none())
        :with_del(cond.none())
    end,
    on_done = function()
      require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })

      if is_package_loaded("cmp") then
        require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())

        -- require("cmp").event:on("confirm_done", function(evt)
        --   if evt.entry.completion_item then
        --     require("nvim-autopairs.completion.cmp").on_confirm_done()(evt)
        --
        --     vim.api.nvim_exec_autocmds("CompleteChanged", {})
        --   end
        -- end)
      end
    end,
  })
end

return M
