return {
  root_dir = function(fname)
    local util = require "lspconfig/util"

    return util.root_pattern { "ansible.cfg", ".git" }(fname) or util.root_pattern { "group_vars", "host_vars" }(fname)
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
  filetypes = { "yaml.ansible" },
}
