local M = {}

function M.create_commands(collection)
  local common_opts = { force = true }
  for _, cmd in pairs(collection) do
    local opts = vim.tbl_deep_extend("force", common_opts, cmd.opts or {})
    vim.api.nvim_create_user_command(cmd.name, cmd.fn, opts)
  end
end

function M.set_option(arr)
  for k, v in pairs(arr) do
    vim.o[k] = v
  end
end

return M
