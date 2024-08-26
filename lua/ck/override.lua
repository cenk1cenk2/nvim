nvim.log.level = "info"

if is_headless() then
  nvim.log.level = "trace"
end

if vim.tbl_contains({ "emanet", "fanboy" }, vim.uv.os_gethostname()) then
  nvim.lsp.automatic_update = false
end

nvim.lsp.copilot.debounce = 50
nvim.lsp.copilot.completion = { "cmp" }
nvim.lsp.copilot.accept_type = "accept"
nvim.lsp.copilot.filetypes = {
  yaml = false,
  markdown = true,
  help = false,
  gitcommit = true,
  gitrebase = false,
  hgcommit = false,
  svn = false,
  cvs = false,
  ["."] = false,
}

nvim.lsp.ensure_installed = {
  ---- language servers
  "jsonls",
  "lua_ls",
  "yamlls",
  "tsserver",
  "bashls",
  "pyright",
  "graphql",
  "grammarly",
  "dockerls",
  "volar",
  "gopls",
  "tailwindcss",
  "cssls",
  "html",
  "svelte",
  "rust_analyzer",
  "ansiblels",
  "emmet_ls",
  "golangci_lint_ls",
  "prismals",
  "prosemd_lsp",
  "taplo",
  "ruff_lsp",
  "docker_compose_language_service",
  "helm_ls",
  "typos_lsp",
  "eslint",

  ---- formatters/linters
  "stylua",
  -- "eslint_d",
  "markdownlint",
  "prettierd",
  "shfmt",
  "black",
  "isort",
  "flake8",
  "shellcheck",
  -- "mypy",
  "golines",
  "goimports",
  "golangci-lint",
  "shellharden",
  "beautysh",
  "hadolint",
  "proselint",
  "bufls",
  "protolint",
  -- "tflint",
  "tfsec",
  "terraform-ls",
  -- "djlint",

  ---- debugers
  "delve",
  "node-debug2-adapter",
  "chrome-debug-adapter",

  -- external
  "markdown-toc",
  -- "md-printer",
  -- "rustywind",
  "checkmake",
}

nvim.lsp.skipped_servers = {
  "angularls",
  -- "ansiblels",
  "denols",
  "ember",
  "csharp_ls",
  "cssmodules_ls",
  -- "emmet_ls",
  -- "eslint",
  "eslintls",
  "glint",
  -- "grammarly",
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
  "sourcery",
  -- "tailwindcss",
  "quick_lint_js",
  "tflint",
  "vuels",
  -- "volar",
  "zk",
  "zeta_note",
}

nvim.lsp.skipped_filetypes = {}

require("ck.setup").setup_callback(require("ck.plugins.treesitter").name, function(c)
  return vim.tbl_extend("force", c, {
    indent = {
      -- TSBufDisable indent
      disable = { "yaml" },
    },
    ensure_installed = {
      "bash",
      "c",
      "c_sharp",
      "cmake",
      "comment",
      "cpp",
      "css",
      "dart",
      "diff",
      "dockerfile",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gotmpl",
      "gowork",
      "graphql",
      "html",
      "htmldjango",
      "http",
      "hurl",
      "java",
      "javascript",
      "jsdoc",
      "json",
      "jsonc",
      "jsonnet",
      "lua",
      "make",
      "markdown",
      "markdown_inline",
      "php",
      "prisma",
      "proto",
      "python",
      "regex",
      "ruby",
      "rust",
      "scss",
      "sql",
      "svelte",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "vue",
      "yaml",
    },
  })
end)
