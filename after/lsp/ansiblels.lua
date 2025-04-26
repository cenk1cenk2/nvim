---@type vim.lsp.ClientConfig
return {
  filetypes = { "yaml.ansible" },
  root_dir = function(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(filename, { "ansible.cfg", ".git" }) or vim.fs.root(filename, { "group_vars", "host_vars" }))
  end,
  settings = {
    ansible = {
      ansible = { useFullyQualifiedCollectionNames = true },
      completion = { provideRedirectModules = true, provideModuleOptionAliases = true },
      ansibleLint = {
        enabled = true,
      },
    },
  },
}
