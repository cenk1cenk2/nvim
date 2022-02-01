M = {}

local TELESCOPE_RG_INTERACTIVE_LAST_ARGS = ""
local telescope = require "lvim.core.telescope"

function M.TelescopeRipgrepInteractive()
  vim.call "inputsave"

  local args = vim.fn.input("Pass in ripgrep arguments" .. " ➜  ", TELESCOPE_RG_INTERACTIVE_LAST_ARGS)

  vim.api.nvim_command "normal :esc<CR>"

  vim.api.nvim_out_write("rg ➜  " .. args .. "\n")

  TELESCOPE_RG_INTERACTIVE_LAST_ARGS = args

  local chunks = {}

  for substring in args:gmatch "%S+" do
    table.insert(chunks, substring)
  end

  local command = ":Telescope live_grep vimgrep_arguments="
    .. table.concat(telescope.rg_arguments, ",")
    .. ","
    .. table.concat(chunks, ",")

  vim.api.nvim_command(command)

  vim.call "inputrestore"
end

function M.DirtyRg()
  return require("telescope.builtin").grep_string {
    search = "",
  }
end

M.setup = function()
  require("utils.command").wrap_to_command {
    {
      "TelescopeRipgrepInteractive",
      'lua require("modules.telescope-rg-interactive").TelescopeRipgrepInteractive()',
    },
    {
      "DirtyRg",
      'lua require("modules.telescope-rg-interactive").DirtyRg()',
    },
  }
end

return M
