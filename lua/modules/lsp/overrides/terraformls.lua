return {
  root_dir = function(fname)
    local util = require("lspconfig/util")

    return util.root_pattern({ ".terraform", ".terraform.lock.hcl", ".git" })(fname)
  end,
  settings = {
    terraform = {
      codelens = { referenceCount = true },
      validation = {
        enableEnhancedValidation = true,
      },
      experimentalFeatures = {
        validateOnSave = true,
        prefillRequiredFields = true,
      },
    },
  },
}
