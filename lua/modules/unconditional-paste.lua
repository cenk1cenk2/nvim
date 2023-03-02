local M = {}

function M.unconditional_paste(after)
  local data = vim.fn.getreg(vim.v.register or lvim.system_register):gsub("^%s*(.-)%s*$", "%1")

  local splitted = vim.split(data, "\n")

  vim.api.nvim_put(splitted, "c", after, true)
end

function M.setup()
  local keymaps = {
    ["gp"] = {
      function()
        M.unconditional_paste(true)
      end,
    },
    ["gP"] = {
      function()
        M.unconditional_paste(false)
      end,
    },
  }

  require("utils.setup").init({
    name = "unconditional_paste",
    keymaps = {
      n = keymaps,
      v = keymaps,
      x = keymaps,
      t = keymaps,
    },
  })
end

return M
