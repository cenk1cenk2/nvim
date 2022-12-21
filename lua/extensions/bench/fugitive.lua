local M = {}

local Log = require "lvim.core.log"

function M.diff()
  vim.ui.input({
    prompt = "Compare current file with branch:",
  }, function(branch)
    if branch == nil then
      Log:warn "Nothing to compare."

      return
    end

    local file = vim.api.nvim_buf_get_name(0)
    Log:info("Comparing with branch: " .. file .. " ➜ " .. branch)

    vim.api.nvim_command(":Gvdiffsplit " .. branch .. ":%")
  end)
end

function M.setup()
  require("utils.setup").configure {
    wk = {
      g = {
        c = {
          function()
            require("modules.fugitive").diff()
          end,
          "compare with branch",
        },
      },
    },
  }
end

return M
