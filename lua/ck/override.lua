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
nvim.lsp.ai.provider.chat = "claude_code"
nvim.lsp.ai.model.chat = nil
nvim.lsp.ai.provider.completion = "copilot"
nvim.lsp.ai.model.completion = nil
nvim.lsp.ai.model.nes = nil

nvim.lsp.ai.debug = false

nvim.lsp.ai.copilot.debounce = 50

nvim.lsp.ai.copilot.nes.enabled = true
nvim.lsp.ai.copilot.nes.auto_suggest = false
nvim.lsp.ai.copilot.nes.debounce = 100


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
  "clangd",
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
  "hyprls",
  "jsonls",
  "jsonnet_ls",
  "laravel_ls",
  "lua_ls",
  "marksman",
  "phpactor",
  "prismals",
  "ruff",
  "rust_analyzer",
  "svelte",
  "systemd_lsp",
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
  -- "vectorcode",
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
  "phpstan",
  "pint",
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

--- treesitter configuration

nvim.treesitter.parsers = {
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
}

nvim.treesitter.custom_parsers = {}

nvim.treesitter.ft_parsers = {
  ["yaml"] = { "yaml.ansible", "yaml.compose", "yaml.gitlab-ci" },
  ["bash"] = { "zsh" },
  ["ini"] = { "confini", "conf" },
}
