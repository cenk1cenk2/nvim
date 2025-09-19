nvim.log.level = "info"
nvim.lsp.log.level = "error"

if is_headless() then
  nvim.log.level = "trace"
end

if vim.tbl_contains({ "emanet" }, vim.uv.os_gethostname()) then
  nvim.lsp.automatic_update = false
end

nvim.lsp.features.inline_completion.enabled = function()
  return vim.tbl_contains(nvim.lsp.ai.completion.provider, "inline")
end

nvim.lsp.features.on_type_formatting.enabled = function(client, bufnr)
  return not vim.tbl_contains({
    "lua",
    "python",
    "yaml",
  }, vim.api.nvim_get_option_value("filetype", { buf = bufnr }))
end

nvim.lsp.features.codelens.enabled = true

nvim.lsp.features.inlay_hints.enabled = true
nvim.lsp.features.inlay_hints.toggled = false
nvim.lsp.features.inlay_hints.mode = "eol"

nvim.lsp.ai.chat.provider = { "codecompanion" }
nvim.lsp.ai.completion.provider = { "inline" }
nvim.lsp.ai.provider.chat = "copilot"
nvim.lsp.ai.model.chat = "claude-sonnet-4"
-- nvim.lsp.ai.provider.chat = "claude"
-- nvim.lsp.ai.model.chat = "claude-sonnet-4-20250514"
nvim.lsp.ai.provider.completion = "copilot"
nvim.lsp.ai.model.completion = nil

nvim.lsp.ai.debug = false

nvim.lsp.ai.copilot.debounce = 75
-- TODO: update me according to the copilot language server
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

nvim.lsp.ai.copilot.nes.enabled = true
nvim.lsp.ai.copilot.nes.auto_suggest = true
nvim.lsp.ai.copilot.nes.debounce = 75
-- nvim.lsp.ai.model.embed = "nomic-embed-text"

-- nvim.lsp.ai.model.embed = "text-embedding-3-small"
-- nvim.lsp.ai.model.completion = "deepseek-coder-v2:16b"
-- nvim.lsp.ai.model.chat = "deepseek-coder-v2:16b"

-- nvim.lsp.ai.completion.number_of_completions = 2
-- nvim.lsp.ai.completion.line_limit = -1
-- nvim.lsp.ai.completion.context_window = 1024 * 4
-- nvim.lsp.ai.completion.vectorcode.enabled = false
-- nvim.lsp.ai.completion.vectorcode.number_of_files = 1
-- nvim.lsp.ai.completion.fim.prefix = "<｜fim▁begin｜>"
-- nvim.lsp.ai.completion.fim.suffix = "<｜fim▁end｜>"
-- nvim.lsp.ai.completion.fim.middle = "<｜fim▁hole｜>"
-- nvim.lsp.ai.completion.fim.file = "<｜file_sep｜>"
-- nvim.lsp.ai.completion.prompt =
--   "Perform fill-in-middle from the following snippet of code. `<｜file_sep｜>` is used to give you additional context with files from the repository. Respond with only the filled-in code."
-- nvim.lsp.ai.completion.options = {
--   max_tokens = 1024,
--   top_p = 0.95,
--   top_k = 10,
-- }
--
-- nvim.lsp.ai.chat.options = {
--   num_ctx = 1024 * 8,
--   top_p = 0.95,
--   top_k = 10,
--   -- num_predict = 8,
-- }

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

---- language servers
nvim.lsp.servers = {
  "ansiblels",
  "bashls",
  "buf_ls",
  "copilot",
  "cssls",
  "dockerls",
  "emmet_ls",
  "eslint",
  "golangci_lint_ls",
  "gopls",
  "graphql",
  "helm_ls",
  "html",
  "intelephense",
  "jsonls",
  "laravel_ls",
  "lua_ls",
  "marksman",
  "prismals",
  "ruff",
  "rust_analyzer",
  "svelte",
  "systemd_ls",
  "tailwindcss",
  "taplo",
  "terraformls",
  "ty",
  "typos_lsp",
  "vale_ls",
  "vtsls",
  "yamlls",
  -- "docker_compose_language_service",
  -- "gitlab_ci_ls",
  -- "pyright",
}

nvim.lsp.packages = vim.list_extend(nvim.lsp.packages, nvim.lsp.servers)

--- lazyloaded language servers as plugins
nvim.lsp.packages = vim.list_extend(nvim.lsp.packages, {
  "vue-language-server",
})

--- formatters/linters
nvim.lsp.packages = vim.list_extend(nvim.lsp.packages, {
  "ansible-lint",
  "beautysh",
  "checkmake",
  "golangci-lint",
  "hadolint",
  "markdown-toc",
  "markdownlint",
  "prettierd",
  "proselint",
  "protolint",
  "selene",
  "shellcheck",
  "shellharden",
  "shfmt",
  "sqruff",
  "stylua",
  "tfsec",
  "vale",
  -- "djlint",
  -- "eslint_d",
  -- "goimports",
  -- "golines",
  -- "mypy",
  -- "tflint",
})

--- debugers
nvim.lsp.packages = vim.list_extend(nvim.lsp.packages, {
  "js-debug-adapter",
  "delve",
})

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
      "editorconfig",
      "git_config",
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
      "helm",
      "html",
      "htmldjango",
      "http",
      "hurl",
      "ini",
      "java",
      "javascript",
      "jinja",
      "jinja_inline",
      "jq",
      "jsdoc",
      "json",
      "json5",
      "jsonc",
      "jsonnet",
      "latex",
      "lua",
      "luadoc",
      "make",
      "markdown",
      "markdown_inline",
      "php",
      "phpdoc",
      "prisma",
      "properties",
      "proto",
      "python",
      "query",
      "regex",
      "requirements",
      "ruby",
      "rust",
      "scss",
      "sql",
      "svelte",
      "terraform",
      "tmux",
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
