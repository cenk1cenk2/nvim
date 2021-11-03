lvim.log.level = "trace"

lvim.lsp.ensure_installed = {
  "jsonls",
  "sumneko_lua",
  "vimls",
  "yamlls",
  "tsserver",
  "bashls",
  "pyright",
  "graphql",
  "dockerls",
  "vuels",
  "stylelint_lsp",
  "gopls",
  "tailwindcss",
  "svelte",
  "angularls",
  "rust_analyzer",
  "eslint",
  "ansiblels",
  -- managed by extensions
  "stylua",
  "eslint_d",
  "markdownlint",
  "prettierd",
  "misspell",
  "markdown_toc",
  "shfmt",
  "black",
  "isort",
  "flake8",
  "mypy",
  "goimports",
  "golines",
  "rustywind",
  "rustfmt",
  "hadolint",
}

lvim.autocommands.custom_groups = {
  TerminalOpen = { "TermOpen", "*", "nnoremap <buffer><LeftRelease> <LeftRelease>i" },
}
