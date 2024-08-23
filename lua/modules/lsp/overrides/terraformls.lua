require("setup").init({
  autocmds = function(_, fn)
    return {
      {
        event = "FileType",
        group = "__lsp",
        pattern = { "terraform", "tfvars" },
        callback = function(event)
          require("setup").load_wk({
            {
              fn.wk_keystroke({ fn.get_wk_category("LSP"), "Q" }),
              function()
                require("modules.lsp.wrapper").reset_buffer_lsp()

                require("core.log"):warn("terraform-ls will be killed.")
                vim.fn.system({ "pkill", "-9", "terraform-ls" })
              end,
              desc = "lsp restart (terraform-ls)",
              buffer = event.buf,
            },
          })
        end,
      },
    }
  end,
})

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
