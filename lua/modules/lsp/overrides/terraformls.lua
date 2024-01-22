return {
  root_dir = function(fname)
    local util = require("lspconfig/util")

    return util.root_pattern({ ".terraform", ".terraform.lock.hcl", ".git" })(fname)
  end,
  settings = {
    terraform = {
      experimentalFeatures = {
        validateOnSave = true,
        prefillRequiredFields = true,
      },
    },
  },
}
