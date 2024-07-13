local M = {}

function M.workspace_quit()
  local buffers = vim.api.nvim_list_bufs()
  local modified = false
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
      modified = true
    end
  end

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
    wk = function(_, categories, fn)
      return {
        {
          fn.build_wk_mapping({ categories.SESSION, "q" }),
          function()
            M.workspace_quit()
          end,
          desc = "quit",
        },
      }
    end,
  })
end

return M
