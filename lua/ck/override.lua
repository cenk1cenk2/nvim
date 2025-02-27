nvim.log.level = "info"

if is_headless() then
  nvim.log.level = "trace"
end

if vim.tbl_contains({ "emanet", "fanboy" }, vim.uv.os_gethostname()) then
  nvim.lsp.automatic_update = false
end

nvim.lsp.codelens.refresh = true

nvim.lsp.inlay_hints.enabled = true
nvim.lsp.inlay_hints.toggled = false
nvim.lsp.inlay_hints.mode = "eol"

nvim.lsp.copilot.debounce = 50
nvim.lsp.copilot.completion = { "inline" }
nvim.lsp.copilot.filetypes = {
  yaml = true,
  markdown = true,
  help = false,
  gitcommit = true,
  gitrebase = false,
  hgcommit = false,
  svn = false,
  cvs = false,
  ["."] = false,
}

nvim.lsp.ai.debug = false

nvim.lsp.ai.provider.completion = "copilot"
nvim.lsp.ai.model.completion = "deepseek-coder-v2:16b"
nvim.lsp.ai.completion.number_of_completions = 1
nvim.lsp.ai.completion.line_limit = -1
nvim.lsp.ai.completion.context_window = 1024 * 4
nvim.lsp.ai.completion.vectorcode.enabled = true
nvim.lsp.ai.completion.vectorcode.number_of_files = 10

nvim.lsp.ai.provider.chat = "copilot"
nvim.lsp.ai.model.chat = "deepseek-coder-v2:16b"
nvim.lsp.ai.chat.context_window = 1024 * 4

nvim.lsp.ai.filetypes.enabled = {
  "*",
}
nvim.lsp.ai.filetypes.ignored = {
  "Telescope",
  "TelescopePrompt",
  "TelescopeResults",
  "Avante",
  "AvanteInput",
}

nvim.lsp.ensure_installed = {
  ---- language servers
  "ansiblels",
  "bashls",
  "buf_ls",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "eslint",
  "gitlab_ci_ls",
  "golangci_lint_ls",
  "gopls",
  "graphql",
  "helm_ls",
  "html",
  "jsonls",
  "lua_ls",
  "markdown_oxide",
  "prismals",
  "pyright",
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "taplo",
  "ts_ls",
  "typos_lsp",
  "vale",
  "vale_ls",
  "volar",
  "yamlls",

  ---- formatters/linters
  "beautysh",
  "black",
  "flake8",
  "goimports",
  "golangci-lint",
  "golines",
  "hadolint",
  "isort",
  "markdownlint",
  "prettierd",
  "proselint",
  "protolint",
  "shellcheck",
  "shellharden",
  "shfmt",
  "stylua",
  "terraform-ls",
  "tfsec",
  -- "djlint",
  -- "eslint_d",
  -- "mypy",
  -- "tflint",

  ---- debugers
  "chrome-debug-adapter",
  "delve",
  "node-debug2-adapter",

  -- external
  "checkmake",
  "markdown-toc",
  -- "md-printer",
  -- "rustywind",
}

nvim.lsp.skipped_servers = {
  "angularls",
  "csharp_ls",
  "cssmodules_ls",
  "denols",
  "ember",
  "eslintls",
  "glint",
  "grammarly",
  "jedi_language_server",
  "ltex",
  "phpactor",
  "prosemd_lsp",
  "pylsp",
  "quick_lint_js",
  "remark_ls",
  "rome",
  "sourcery",
  "spectral",
  "sqlls",
  "sqls",
  "stylelint_lsp",
  "tflint",
  "vuels",
  "zeta_note",
  "zk",
  -- "ansiblels",
  -- "emmet_ls",
  -- "eslint",
  -- "graphql",
  -- "tailwindcss",
  -- "volar",
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
      "hcl",
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
      "latex",
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
      "xml",
      "yaml",
    },
  })
end)
