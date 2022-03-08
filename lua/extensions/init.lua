local M = {}

local extensions = {
  "extensions.neotree-nvim",
  "extensions.alpha-nvim",
  "extensions.neovim-session-manager",
  "extensions.hop",
  "extensions.vim-repeat",
  "extensions.vim-surround",
  "extensions.neoscroll",
  "extensions.spectre",
  "extensions.rnvimr",
  "extensions.vim-better-whitespace",
  "extensions.vim-visual-multi",
  "extensions.vim-maximizer",
  "extensions.vim-windowswap",
  "extensions.undotree",
  "extensions.cmp-extensions",
  "extensions.nvim-bqf",
  "extensions.lsp-trouble",
  "extensions.symbols-outline",
  "extensions.colorizer",
  "extensions.todo-comments",
  "extensions.indent-blankline",
  "extensions.vim-fugitive",
  "extensions.octo",
  "extensions.diffview",
  "extensions.vim-easy-align",
  "extensions.markdown-preview",
  "extensions.nvim-neoclip",
  "extensions.vim-bookmarks",
  "extensions.package-info",
  "extensions.neogen",
  "extensions.coc",
  "extensions.distant",
  "extensions.nvim-dap-ui",
  "extensions.vim-jinja",
  "extensions.nvim-orgmode",
  "extensions.dressing",
  "extensions.vim-caser",
  "extensions.aerojump-nvim",
  "extensions.nvim-hlslens",
  "extensions.nvim-scrollbar",
  "extensions.fidget-nvim",
  "extensions.vim-unconditionalpaste",
  "extensions.vim-unimpaired",
  "extensions.refactoring-nvim",
  "extensions.lsp-lines-nvim",
}

function M.config(config)
  for _, extension_path in ipairs(extensions) do
    local extension = require(extension_path)
    extension.config(config)
  end
end

return M
