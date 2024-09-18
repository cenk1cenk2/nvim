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
          chars = { "{", "[", "(", '"', "'", "`", "<" },
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

      npairs.add_rule(Rule("|", "|", "rust"))

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

      local get_closing_for_line = function(line)
        local i = -1
        local clo = ""

        while true do
          i, _ = string.find(line, "[%(%)%{%}%[%]]", i + 1)
          if i == nil then
            break
          end
          local ch = string.sub(line, i, i)
          local st = string.sub(clo, 1, 1)

          if ch == "{" then
            clo = "}" .. clo
          elseif ch == "}" then
            if st ~= "}" then
              return ""
            end
            clo = string.sub(clo, 2)
          elseif ch == "(" then
            clo = ")" .. clo
          elseif ch == ")" then
            if st ~= ")" then
              return ""
            end
            clo = string.sub(clo, 2)
          elseif ch == "[" then
            clo = "]" .. clo
          elseif ch == "]" then
            if st ~= "]" then
              return ""
            end
            clo = string.sub(clo, 2)
          end
        end

        return clo
      end

      local brackets = {
        { "(", ")" },
        { "[", "]" },
        { "{", "}" },
      }
      npairs.add_rules({
        -- Rule for a pair with left-side ' ' and right side ' '
        Rule(" ", " ")
          -- Pair will only occur if the conditional function returns true
          :with_pair(function(opts)
            -- We are checking if we are inserting a space in (), [], or {}
            local pair = opts.line:sub(opts.col - 1, opts.col)
            return vim.tbl_contains(
              vim.tbl_map(function(bracket)
                return bracket[1] .. bracket[2]
              end, brackets),
              pair
            )
          end)
          :with_move(cond.none())
          :with_cr(cond.none())
          -- We only want to delete the pair of spaces when the cursor is as such: ( | )
          :with_del(function(opts)
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local context = opts.line:sub(col - 1, col + 2)
            return cond.not_filetypes({ "markdown", "jinja", "gotmpl" })
              and vim.tbl_contains(
                vim.tbl_map(function(bracket)
                  return bracket[1] .. bracket[2]
                end, brackets),
                context
              )
          end),
      })

      -- For each pair of brackets we will add another rule
      for _, bracket in pairs(brackets) do
        npairs.add_rules({
          -- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
          Rule(bracket[1] .. " ", " " .. bracket[2])
            :with_pair(cond.none())
            :with_move(function(opts)
              return opts.char == bracket[2]
            end)
            :with_del(cond.none())
            :use_key(bracket[2])
            -- Removes the trailing whitespace that can occur without this
            :replace_map_cr(function(_)
              return "<C-c>2xi<CR><C-c>O"
            end),
        })
      end

      npairs.add_rules({
        npairs.add_rule,
        -- npairs.add_rule(Rule("[%(%{%[]", "")
        --   :use_regex(true)
        --   :replace_endpair(function(opts)
        --     return get_closing_for_line(opts.line)
        --   end)
        --   :end_wise(function(opts)
        --     -- Do not endwise if there is no closing
        --     return get_closing_for_line(opts.line) ~= ""
        --   end)),

        -- auto-pair <> for generics but not as greater-than/less-than operators
        npairs.add_rule(Rule("<", ">", {
          -- if you use nvim-ts-autotag, you may want to exclude these filetypes from this rule
          -- so that it doesn't conflict with nvim-ts-autotag
          "-html",
          "-javascriptreact",
          "-typescriptreact",
        }):with_pair(
          -- regex will make it so that it will auto-pair on
          -- `a<` but not `a <`
          -- The `:?:?` part makes it also
          -- work on Rust generics like `some_func::<T>()`
          cond.before_regex("%a+:?:?$", 3)
        ):with_move(function(opts)
          return opts.char == ">"
        end)),

        rule_context_aware_expand("{{", " ", "}}", "jinja"),
        rule_context_aware_expand("{%", " ", "%}", "jinja"),

        -- arrow key on javascript
        Rule("%(.*%)%s*%=>$", " {}", {
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
            "lua",
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
      end
    end,
  })
end

return M
