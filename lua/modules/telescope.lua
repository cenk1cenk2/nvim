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

    local command = ":Telescope live_grep vimgrep_arguments="
      .. table.concat(telescope.rg_arguments, ",")
      .. ","
      .. table.concat(chunks, ",")

    vim.api.nvim_command(command)
  end)
end

function M.rg_string()
  local chunks = { "--fixed-strings" }

  local command = ":Telescope live_grep vimgrep_arguments="
    .. table.concat(telescope.rg_arguments, ",")
    .. ","
    .. table.concat(chunks, ",")

  vim.api.nvim_command(command)
end

function M.rg_dirty()
  return require("telescope.builtin").grep_string {
    search = "",
  }
end

return M
