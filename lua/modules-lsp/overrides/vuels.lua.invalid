local opts = {
  root_dir = function(fname)
    local util = require "lspconfig/util"

    return util.root_pattern "package.json"(fname) or util.root_pattern "vue.config.js"(fname) or vim.fn.getcwd()
  end,
  settings = {
    vetur = {
      completion = { autoImport = true, tagCasing = "kebab", useScaffoldSnippets = true },
      experimental = { templateInterpolationService = true },
      useWorkspaceDependencies = true,
      validation = { script = true, style = true, template = true },
    },
  },
  handlers = {
    ["codeAction/resolve"] = function(_, _, params, _, bufnr, _)
      vim.lsp.buf_request_sync(bufnr, "codeAction/resolve", params)
    end,
  },
}
return opts
