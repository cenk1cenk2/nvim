require("ck.setup").init({
  autocmds = function()
    return {
      require("ck.modules.autocmds").init_with({ "FileType" }, { "terraform", "tfvars" }, function(event)
        return {
          wk = function(_, categories, fn)
            ---@type WKMappings
            return {
              {
                fn.wk_keystroke({ categories.LSP, "Q", "Q" }),
                function()
                  nvim.lsp.fn.restart_lsp()

                  require("ck.log"):warn("terraform-ls will be killed.")
                  vim.fn.system({ "pkill", "-9", "terraform-ls" })
                end,
                desc = "lsp restart (terraform-ls)",
                buffer = event.buf,
              },
            }
          end,
        }
      end),
    }
  end,
})

---@module "lspconfig"
---@type lspconfig.options.terraformls
return {
  root_dir = function(fname)
    return vim.fs.root(fname, { ".terraform", ".terraform.lock.hcl", ".git" })
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
