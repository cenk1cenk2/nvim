local M = {}

local extensions = {
  'extensions.hop',
  'extensions.vim-repeat',
  'extensions.vim-surround',
  'extensions.neoscroll',
  'extensions.spectre',
  'extensions.rnvimr',
  'extensions.vim-better-whitespace',
  'extensions.vim-visual-multi',
  'extensions.vim-maximizer',
  'extensions.vim-windowswap',
  'extensions.undotree',
  'extensions.nvim-bqf',
  'extensions.lsp-trouble',
  'extensions.symbols-outline',
  'extensions.colorizer',
  'extensions.todo-comments',
  'extensions.indent-blankline',
  'extensions.vim-fugitive',
  'extensions.octo',
  'extensions.diffview',
  'extensions.vim-easy-align',
  'extensions.markdown-preview',
  'extensions.nvim-neoclip',
  'extensions.vim-bookmarks',
  'extensions.package-info',
  'extensions.neogen',
  'extensions.coc'
}

function M.config(config)
  for _, extension_path in ipairs(extensions) do
    local extension = require(extension_path)
    extension.config(config)
  end
end

return M