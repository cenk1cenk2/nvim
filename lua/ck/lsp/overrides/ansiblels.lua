---@module "lspconfig"
---@type lspconfig.options.ansiblels
return {
  filetypes = { "yaml.ansible" },
  root_dir = function(filename)
    return vim.fs.root(filename, { "ansible.cfg", ".git" }) or vim.fs.root(filename, { "group_vars", "host_vars" })
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
