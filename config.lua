lvim.log.level = "info"

lvim.lsp.ensure_installed = {
  ---- language servers
  "json-lsp",
  "lua-language-server",
  "yaml-language-server",
  "typescript-language-server",
  "bash-language-server",
  "pyright",
  "graphql-language-service-cli",
  "grammarly-languageserver",
  "dockerfile-language-server",
  "vue-language-server",
  "gopls",
  "tailwindcss-language-server",
  "svelte-language-server",
  "rust-analyzer",
  "ansible-language-server",
  "emmet-ls",
  "golangci-lint-langserver",
  "prisma-language-server",
  "prosemd-lsp",
  "taplo",
  ---- formatters/linters
  "stylua",
  "eslint_d",
  "markdownlint",
  "markdown-toc",
  "prettierd",
  "misspell",
  "shfmt",
  "black",
  "isort",
  "flake8",
  "shellcheck",
  -- "mypy",
  -- "goimports",
  "golines",
  "golangci-lint",
  "shellharden",
  "beautysh",
  "codespell",
  -- "checkmake",
  -- "revive",
  -- "rustfmt",
  "hadolint",
  -- "proselint",
  "terraform-ls",
  -- "djlint",
  ---- debugers
  "delve",
  "node-debug2-adapter",
  "chrome-debug-adapter",
  -- external
  "markdown-toc",
  "rustywind",
}

lvim.lsp.automatic_configuration.skipped_filetypes = {}

lvim.lsp.ignored_formatters = {
  "tsserver",
}

lvim.lsp.automatic_configuration.skipped_servers = {
  "angularls",
  -- "ansiblels",
  "denols",
  "ember",
  "csharp_ls",
  "cssmodules_ls",
  -- "emmet_ls",
  "eslint",
  "eslintls",
  -- "graphql",
  "jedi_language_server",
  "ltex",
  "phpactor",
  "pylsp",
  "rome",
  "spectral",
  "sqlls",
  "sqls",
  "remark_ls",
  "stylelint_lsp",
  -- "tailwindcss",
  "quick_lint_js",
  "tflint",
  "vuels",
  -- "volar",
  "zk",
  "zeta_note",
}

lvim.extensions.treesitter.to_setup.ensure_installed = {
  "bash",
  "c",
  "c_sharp",
  "cmake",
  "comment",
  "cpp",
  "css",
  "dart",
  "dockerfile",
  "go",
  "graphql",
  "html",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "julia",
  "lua",
  "php",
  "python",
  "regex",
  "ruby",
  "rust",
  "scss",
  "svelte",
  "tsx",
  "typescript",
  "vue",
  "yaml",
}

lvim.lsp.null_ls.setup = {
  debug = false,
}

lvim.extensions.dap.on_complete = function(config)
  local dap = config.inject.dap

  dap.adapters.node2 = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug.js" },
  }

  -- Chrome
  dap.adapters.chrome = {
    type = "executable",
    command = "node",
    args = { vim.fn.stdpath "data" .. "/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js" },
  }

  dap.configurations.javascript = {
    {
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
    },
  }
end
