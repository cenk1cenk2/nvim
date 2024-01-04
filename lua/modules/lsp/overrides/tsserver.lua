return {
  override = function(config)
    -- typescript-tools if this is enabled it will override it
    require("typescript-tools").setup(config)
  end,
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  single_file_support = false,
  settings = {
    -- https://github.com/pmizio/typescript-tools.nvim#%EF%B8%8F-configuration
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = false,
    -- "change"|"insert_leave" determine when the client asks the server about diagnostic
    publish_diagnostic_on = "insert_leave",
    -- array of strings("fix_all"|"add_missing_imports"|"remove_unused")
    -- specify commands exposed as code_actions
    expose_as_code_action = { "add_missing_imports", "remove_unused" },
    -- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
    -- not exists then standard path resolution strategy is applied
    tsserver_path = nil,
    -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
    -- (see 💅 `styled-components` support section)
    tsserver_plugins = {},
    -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
    -- memory limit in megabytes or "auto"(basically no limit)
    tsserver_max_memory = "auto",
    -- CodeLens
    -- possible values: ("off"|"all"|"implementations_only"|"references_only")
    code_lens = "off",
    -- by default code lenses are displayed on all referencable values and for some of you it can
    -- be too much this option reduce count of them by removing member references from lenses
    disable_member_code_lens = true,
    -- described below
    tsserver_format_options = {},
    tsserver_file_preferences = {
      includeCompletionsForModuleExports = true,
      quotePreference = "single",
      includeCompletionsForImportStatements = true,
      includeAutomaticOptionalChainCompletions = true,
      includeCompletionsWithClassMemberSnippets = true,
      includeCompletionsWithObjectLiteralMethodSnippets = true,
      importModuleSpecifierPreference = "shortest",
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
    typescript = {
      preferences = {
        importModuleSpecifier = "relative",
      },
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  commands = {
    -- LspRenameFile = {
    --   function()
    --     local current = vim.api.nvim_buf_get_name(0)
    --     vim.ui.input({ prompt = "Set the path to rename to" .. " ➜  ", default = current }, function(rename)
    --       if not rename then
    --         vim.notify("File name can not be empty.", vim.log.levels.ERROR)
    --
    --         return
    --       end
    --
    --       vim.notify(current .. " ➜  " .. rename)
    --
    --       local stat = vim.uv.fs_stat(rename)
    --
    --       if stat and stat.type then
    --         vim.notify("File already exists: " .. rename, vim.log.levels.ERROR)
    --
    --         return
    --       end
    --
    --       vim.lsp.buf.execute_command({
    --         command = "_typescript.applyRenameFile",
    --         arguments = { { sourceUri = "file://" .. current, targetUri = "file://" .. rename } },
    --         title = "",
    --       })
    --
    --       vim.uv.fs_rename(current, rename)
    --
    --       for _, buf in pairs(vim.api.nvim_list_bufs()) do
    --         if vim.api.nvim_buf_is_loaded(buf) then
    --           if vim.api.nvim_buf_get_name(buf) == current then
    --             vim.api.nvim_buf_set_name(buf, rename)
    --             -- to avoid the 'overwrite existing file' error message on write
    --             vim.api.nvim_buf_call(buf, function()
    --               vim.cmd("silent! w!")
    --             end)
    --           end
    --         end
    --       end
    --     end)
    --   end,
    -- },
    --
    LspOrganizeImports = {
      function()
        -- vim.lsp.buf.execute_command({
        --   command = "_typescript.organizeImports",
        --   arguments = { vim.api.nvim_buf_get_name(0) },
        --   title = "",
        -- })

        vim.cmd([[TSToolsOrganizeImports]])
      end,
    },
    LspAddMissingImports = {
      function()
        vim.cmd([[TsToolsAddMissingImports]])
      end,
    },
  },
}
