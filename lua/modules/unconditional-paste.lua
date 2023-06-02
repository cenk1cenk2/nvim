local M = {}

function M.unconditional_paste(after)
  local lines = vim.fn.getreg(vim.v.register or lvim.system_register):gsub("^%s*(.-)%s*$", "%1")

  vim.api.nvim_paste(lines, false, -1)
end

function M.setup()
  require("utils.setup").init({
    name = "unconditional_paste",
    keymaps = {
      {
        { "n", "v", "x", "t" },

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
      },
    },
  })
end

return M
