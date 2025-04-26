---@type vim.lsp.ClientConfig
return {
  on_new_config = function(new_config, root_dir)
    local pipfile = vim.fs.root(root_dir, { "Pipfile" })

    if pipfile then
      new_config.cmd = { "pipenv", "run", "pyright-langserver", "--stdio" }
    end
  end,
}
