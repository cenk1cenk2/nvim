-- require("ck.setup").init({
--   autocmds = function()
--     return {
--       require("ck.modules.autocmds").init_with({ "FileType" }, { "terraform", "tfvars" }, function(event)
--         return {
--           wk = function(_, categories, fn)
--             ---@type WKMappings
--             return {
--               {
--                 fn.wk_keystroke({ categories.LSP, "Q", "Q" }),
--                 function()
--                   nvim.lsp.fn.restart_lsp()
--
--                   require("ck.log"):warn("terraform-ls will be killed.")
--                   vim.fn.system({ "pkill", "-9", "terraform-ls" })
--                 end,
--                 desc = "lsp restart (terraform-ls)",
--                 buffer = event.buf,
--               },
--             }
--           end,
--         }
--       end),
--     }
--   end,
-- })
--
---@type vim.lsp.ClientConfig
return {
  root_dir = function(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(filename, { ".terraform", ".terraform.lock.hcl", ".git" }))
  end,

  -- Correct key for terraform-ls: init_options (not settings)
  init_options = {
    -- Exclude directories to prevent indexing issues
    indexing = {
      ignorePaths = {
        ".terraform/**",
        "**/.terraform/**",
        "node_modules/**",
        "**/node_modules/**",
        ".terragrunt-cache/**",
        "**/.terragrunt-cache/**",
      },
    },

    -- Disable expensive validation features that can cause hangs
    validation = {
      enableEnhancedValidation = false,
    },

    experimentalFeatures = {
      validateOnSave = true,
      prefillRequiredFields = true,
    },

    -- Log Terraform CLI executions for debugging
    terraform = {
      timeout = "30s",
    },
  },
}
