---@type vim.lsp.ClientConfig
return {
  filetypes = {
    "javascript",
    "js",
    "jsx",
    "ts",
    "tsx",
    "typescript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    -- TODO: here the CSS autocompletion does not work from svelte language server so it is enabled explicitly
    "svelte",
  },
  on_attach = function(client, bufnr)
    require("ck.lsp.handlers").on_attach(client, bufnr)
    require("ck.lsp.handlers").overwrite_capabilities_with_no_formatting(client, bufnr)
  end,
  before_init = function(params, config)
    local packages = vim.fn.expand("$MASON/packages")

    table.insert(config.settings.vtsls.tsserver.globalPlugins, {
      name = "@vue/typescript-plugin",
      -- TODO: can not do this programatically right now
      location = join_paths(packages, "vue-language-server/node_modules/@vue/language-server"),
      languages = { "vue" },
      configNamespace = "typescript",
      enableForWorkspaceTypeScriptVersions = true,
    })

    table.insert(config.settings.vtsls.tsserver.globalPlugins, {
      name = "typescript-svelte-plugin",
      -- TODO: can not do this programatically right now
      location = join_paths(packages, "svelte-language-server"),
      languages = { "svelte" },
      configNamespace = "typescript",
      enableForWorkspaceTypeScriptVersions = true,
    })
  end,
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
      tsserver = {
        globalPlugins = {},
      },
    },
  },
}
