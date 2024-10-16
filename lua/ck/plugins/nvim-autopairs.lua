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

      npairs.add_rules({
        Rule("|", "|", "rust"),
      })

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
      npairs.add_rules(vim.tbl_map(function(bracket)
        return Rule(bracket[1], bracket[2]):with_pair(cond.not_filetypes({ "markdown", "jinja", "gotmpl" })):with_move(cond.none()):with_cr(cond.none()):with_del(cond.none())
      end, brackets))

      npairs.add_rules({
        -- auto-pair <> for generics but not as greater-than/less-than operators
        Rule("<", ">", {
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
        end),
      })

      require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })

      if is_loaded("cmp") then
        require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  })
end

return M
