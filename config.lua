lvim.log.level = "debug"

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
}

lvim.autocommands.custom_groups = {
  TerminalOpen = { "TermOpen", "*", "nnoremap <buffer><LeftRelease> <LeftRelease>i" },
}
