local M = {}

function M.workspace_quit()
  local bufnr = vim.api.nvim_get_current_buf()
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  if modified then
    vim.ui.input({
      prompt = "You have unsaved changes. Quit anyway? (y/n) ",
    }, function(input)
      if input == "y" then
        vim.cmd("qa!")
      end
    end)
  else
    vim.cmd("qa!")
  end
end

function M.setup()
  require("utils.setup").init({
    name = "quit",
    wk = function(_, categories)
      return {
        [categories.SESSION] = {
          name = "session",
          q = {
            function()
              M.workspace_quit()
            end,
            "quit",
          },
        },
      }
    end,
  })
end

return M
