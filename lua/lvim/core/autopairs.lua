local M = {}

function M.config()
  lvim.builtin.autopairs = {
    active = true,
    on_config_done = nil,
    ---@usage  -- modifies the function or method delimiter by filetypes
    map_char = {
      all = "(",
      tex = "{",
    },
    ---@usage check treesitter
    check_ts = true,
    ts_config = { lua = { "string" }, javascript = { "template_string" }, java = false },
  }
end

M.setup = function()
  local autopairs = require "nvim-autopairs"
  local Rule = require "nvim-autopairs.rule"

  autopairs.setup { check_ts = lvim.builtin.autopairs.check_ts, ts_config = lvim.builtin.autopairs.ts_config }

  local cmp_status_ok, cmp = pcall(require, "cmp")
  if cmp_status_ok then
    -- If you want insert `(` after select function or method item
    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
    local map_char = lvim.builtin.autopairs.map_char
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = map_char })
  end

  require("nvim-treesitter.configs").setup { autopairs = { enable = true } }

  local ts_conds = require "nvim-autopairs.ts-conds"

  -- TODO: can these rules be safely added from "config.lua" ?
  -- press % => %% is only inside comment or string
  autopairs.add_rules {
    Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node { "string", "comment" }),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node { "function" }),
  }

  if lvim.builtin.autopairs.on_config_done then
    lvim.builtin.autopairs.on_config_done(autopairs)
  end
end

return M
