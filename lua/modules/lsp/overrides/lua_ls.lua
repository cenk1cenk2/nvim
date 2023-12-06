local neodev_loaded, neodev = pcall(require, "neodev")
local options = {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}

if neodev_loaded then
  neodev.setup({
    library = {
      vimruntime = true, -- runtime path
      types = true,      -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      -- plugins = true, -- installed opt or start plugins in packpath
      -- you can also specify the list of plugins to make available as a workspace library
      plugins = { "plenary.nvim" },
    },
    override = nil, -- function(root_dir, options) end,
  })

  options = vim.tbl_extend("force", options, {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "lvim" },
        },
        workspace = {
          library = {
            vim.fn.expand("$VIMRUNTIME"),
            get_config_dir(),
            neodev.types(),
            "${3rd}/busted/library",
            "${3rd}/luassert/library",
          },
          checkThirdParty = false,
          maxPreload = 5000,
          preloadFileSize = 10000,
        },
      },
    },
  })
end

return options
