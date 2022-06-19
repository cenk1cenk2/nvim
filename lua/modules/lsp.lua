local M = {}

M.LspSetup = function()
  vim.call "inputsave"

  local server = vim.fn.input("Server to start" .. " ➜ ")

  vim.api.nvim_command "normal :esc<CR>"

  require("lvim.lsp.manager").setup(server)

  vim.call "inputrestore"
end

M.setup = function()
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
