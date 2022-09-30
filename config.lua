lvim.log.level = "debug"

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
  "grammarly",
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
  local get_debugger = config.inject.get_debugger

  -- adapters
  dap.adapters.node2 = {
    type = "executable",
    command = get_debugger "node-debug2-adapter",
    args = {},
  }

  -- Chrome
  dap.adapters.chrome = {
    type = "executable",
    command = get_debugger "chrome-debug-adapter",
    args = {},
  }

  dap.adapters.go.command = get_debugger "dlv"

  -- configurations
  dap.configurations.javascript = {
    {
      name = "Launch",
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = "Attach to process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
  }

  dap.configurations.typescript = {
    {
      name = "Launch",
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      -- For this to work you need to make sure the node process is started with the `--inspect` flag.
      name = "Attach to process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
    },
  }

  dap.configurations.javascriptreact = { -- change this to javascript if needed
    {
      name = "attach with chrome",
      type = "chrome",
      request = "attach",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}",
    },
  }

  dap.configurations.typescriptreact = { -- change to typescript if needed
    {
      name = "attach with chrome",
      type = "chrome",
      request = "attach",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}",
    },
  }

  -- -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  -- dap.configurations.go = {
  --   {
  --     name = "Debug",
  --     type = "delve",
  --     request = "launch",
  --     program = "${file}",
  --   },
  --   {
  --     name = "Debug test", -- configuration for debugging test files
  --     type = "delve",
  --     request = "launch",
  --     mode = "test",
  --     program = "${file}",
  --   },
  --   -- works with go.mod packages and sub packages
  --   {
  --     name = "Debug test (go.mod)",
  --     type = "delve",
  --     request = "launch",
  --     mode = "test",
  --     program = "./${relativeFileDirname}",
  --   },
  -- }
end
