nvim.log.level = "info"

if is_headless() then
  nvim.log.level = "trace"
end

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

nvim.lsp.skipped_filetypes = {}

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

require("ck.setup").fn.append_to_setup(get_plugin_name("treesitter"), {
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
    "json6",
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
