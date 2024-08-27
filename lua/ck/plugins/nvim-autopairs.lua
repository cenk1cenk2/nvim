-- https://github.com/windwp/nvim-autopairs

local M = {}

M.name = "windwp/nvim-autopairs"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "windwp/nvim-autopairs",
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
        disable_filetype = nvim.disabled_filetypes,
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
          keys = nvim.selection_chars,
          check_comma = true,
          highlight = "AutoPairsFastWrap",
          highlight_grey = "",
        },
      }
    end,
    on_setup = function(c)
      require("nvim-autopairs").setup(c)
    end,
    on_done = function()
      -- https://github.com/windwp/nvim-autopairs/wiki/Custom-rules

      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      local rule_context_aware_expand = function(a1, ins, a2, lang)
        npairs.add_rule(Rule(ins, ins, lang)
          :with_pair(function(opts)
            return a1 .. a2 == opts.line:sub(opts.col - #a1, opts.col + #a2 - 1)
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            return a1 .. ins .. ins .. a2 == opts.line:sub(col - #a1 - #ins + 1, col + #ins + #a2) -- insert only works for #ins == 1 anyway
          end))
      end

      local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }

      npairs.add_rules({
        -- Add spaces between parentheses
        Rule(" ", " ")
          -- Pair will only occur if the conditional function returns true
          :with_pair(function(opts)
            -- We are checking if we are inserting a space in (), [], or {}
            return cond.not_filetypes({ "markdown", "jinja", "gotmpl" })
              and vim.tbl_contains({
                brackets[1][1] .. brackets[1][2],
                brackets[2][1] .. brackets[2][2],
                brackets[3][1] .. brackets[3][2],
              }, opts.line:sub(opts.col - 1, opts.col))
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          -- We only want to delete the pair of spaces when the cursor is as such: ( | )
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return vim.tbl_contains({
              brackets[1][1] .. "  " .. brackets[1][2],
              brackets[2][1] .. "  " .. brackets[2][2],
              brackets[3][1] .. "  " .. brackets[3][2],
            }, context)
          end),

        -- angle brackets
        Rule("<", ">"):with_pair(cond.before_regex("%a+")),

        rule_context_aware_expand("{{", " ", "}}", "jinja"),
        rule_context_aware_expand("{%", " ", "%}", "jinja"),

        -- arrow key on javascript
        Rule("%(.*%)%s*%=>$", " {  }", {
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "vue",
          "svelte",
        }):use_regex(true):set_end_pair_length(2),

        -- auto addspace on =
        Rule("=", "", {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
            "vue",
            "go",
          })
          :with_pair(cond.not_inside_quote)
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
          :with_del(cond.none()),
      })

      require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })

      if is_loaded("cmp") then
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
