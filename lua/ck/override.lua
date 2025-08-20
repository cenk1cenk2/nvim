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

nvim.lsp.ai.debug = false

nvim.lsp.ai.provider.completion = "copilot"
nvim.lsp.ai.provider.chat = "copilot"
nvim.lsp.ai.chat.rag = false
nvim.lsp.ai.copilot.chat.model = "claude-opus-4.1"
nvim.lsp.ai.copilot.debounce = 50
nvim.lsp.ai.copilot.nes.enabled = false
nvim.lsp.ai.copilot.nes.debounce = 50
nvim.lsp.ai.copilot.nes.auto_suggest = true
nvim.lsp.ai.copilot.completion.provider = { "inline" }
nvim.lsp.ai.copilot.filetypes = {
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

-- nvim.lsp.ai.model.embed = "nomic-embed-text"
nvim.lsp.ai.model.embed = "text-embedding-3-small"
nvim.lsp.ai.model.completion = "deepseek-coder-v2:16b"
nvim.lsp.ai.completion.number_of_completions = 2
nvim.lsp.ai.completion.line_limit = -1
nvim.lsp.ai.completion.context_window = 1024 * 4
nvim.lsp.ai.completion.vectorcode.enabled = true
nvim.lsp.ai.completion.vectorcode.number_of_files = 1
nvim.lsp.ai.completion.fim.prefix = "<｜fim▁begin｜>"
nvim.lsp.ai.completion.fim.suffix = "<｜fim▁end｜>"
nvim.lsp.ai.completion.fim.middle = "<｜fim▁hole｜>"
nvim.lsp.ai.completion.fim.file = "<｜file_sep｜>"
nvim.lsp.ai.completion.prompt =
  "Perform fill-in-middle from the following snippet of code. `<｜file_sep｜>` is used to give you additional context with files from the repository. Respond with only the filled-in code."
nvim.lsp.ai.completion.options = {
  max_tokens = 1024,
  top_p = 0.95,
  top_k = 10,
}

nvim.lsp.ai.model.chat = "deepseek-coder-v2:16b"
nvim.lsp.ai.chat.options = {
  num_ctx = 1024 * 8,
  top_p = 0.95,
  top_k = 10,
  -- num_predict = 8,
}

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

nvim.lsp.servers = {
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
  "systemd_ls",
  "tailwindcss",
  "terraformls",
  "taplo",
  "vtsls",
  "typos_lsp",
  "vale",
  "vale_ls",
  -- TODO: https://github.com/mason-org/mason-lspconfig.nvim/issues/371
  -- "volar",
  "yamlls",
}

nvim.lsp.packages = vim.list_extend({
  --- language servers
  "copilot-language-server",

  --- formatters/linters
  "ansible-lint",
  "beautysh",
  "golangci-lint",
  "hadolint",
  "markdownlint",
  "prettierd",
  "proselint",
  "protolint",
  "shellcheck",
  "shellharden",
  "shfmt",
  "sqruff",
  "stylua",
  "tfsec",
  -- "djlint",
  -- "eslint_d",
  -- "goimports",
  -- "golines",
  -- "mypy",
  -- "tflint",

  --- debugers
  "chrome-debug-adapter",
  "delve",
  "node-debug2-adapter",

  -- external
  "checkmake",
  "markdown-toc",
  -- "md-printer",
  -- "rustywind",
}, nvim.lsp.servers)

require("ck.setup").setup_callback(require("ck.plugins.treesitter").name, function(c)
  return vim.tbl_extend("force", c, {
    indent = {
      -- TSBufDisable indent
      -- disable = { "yaml" },
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
