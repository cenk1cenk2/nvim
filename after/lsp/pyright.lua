---@type vim.lsp.ClientConfig
return {
  on_new_config = function(new_config, root_dir)
    -- if vim.fs.root(root_dir, { "uv.lock" }) then
    --   new_config.cmd = { "uv", "run", "pyright-langserver", "--stdio" }
    -- elseif vim.fs.root(root_dir, { "Pipfile" }) then
    --   new_config.cmd = { "pipenv", "run", "pyright-langserver", "--stdio" }
    -- end
  end,
}
