-- require("utils.setup").init({
--   autocmds = function(_, fn)
--     return {
--       {
--         "FileType",
--         {
--           group = "__lsp",
--           pattern = { "terraform", "tfvars" },
--           callback = function(event)
--             require("utils.setup").load_wk({
--               {
--                 { "n" },
--                 [fn.get_wk_category("LSP")] = {
--                   ["Q"] = {
--                     function()
--                       local clients = vim.lsp.get_clients({ bufnr = event.buf })
--
--                       for _, client in pairs(clients) do
--                         vim.lsp.stop_client(client.id, true)
--                       end
--
--                       require("lvim.core.log"):warn("terraform-ls will be killed.")
--                       -- vim.fn.system({ "pkill", "-9", "terraform-ls" })
--                       -- vim.cmd([[e]])
--                     end,
--                     "lsp restart (terraform-ls)",
--                   },
--                 },
--               },
--             }, {
--               buffer = event.buf,
--             })
--           end,
--         },
--       },
--     }
--   end,
-- })

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
