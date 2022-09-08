M = {}

local telescope = require "lvim.core.telescope"
local Log = require "lvim.core.log"

function M.rg_interactive()
  local store_key = "TELESCOPE_RG_INTERACTIVE_LAST_ARGS"
  local stored_value = lvim.store.get_store(store_key)

  vim.ui.input({
    prompt = "Pass in rg args:",
    default = stored_value,
  }, function(args)
    if args == nil then
      Log:warn "Nothing to do."

      return
    end

    lvim.store.set_store(store_key, args)

    local chunks = {}

    for substring in args:gmatch "%S+" do
      table.insert(chunks, substring)
    end

    return require("telescope.builtin").live_grep {
      vimgrep_arguments = vim.list_extend(vim.deepcopy(telescope.rg_arguments), chunks),
    }
  end)
end

function M.rg_string()
  return require("telescope.builtin").live_grep {
    vimgrep_arguments = vim.list_extend(vim.deepcopy(telescope.rg_arguments), { "--fixed-strings" }),
  }
end

function M.rg_dirty()
  require("telescope.builtin").grep_string { shorten_path = true, word_match = "-w", only_sort_text = true, search = "" }
end

function M.rg_grep_buffer()
  return require("telescope.builtin").live_grep { search_dirs = { "%:p" } }
end

return M
