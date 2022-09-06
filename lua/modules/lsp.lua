local M = {}

function M.LspSetup()
  vim.call "inputsave"

  local server = vim.fn.input("Server to start" .. " ➜ ")

  vim.api.nvim_command "normal :esc<CR>"

  require("lvim.lsp.manager").setup(server)

  vim.call "inputrestore"
end

function M.setup()
  require("utils.command").create_commands {
    {
      name = "LspSetup",
      fn = function()
        M.LspSetup()
      end,
    },
  }
end

return M
