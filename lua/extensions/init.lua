local M = {}

local extensions = {
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
  'extensions.colorizer'
}

function M.config(config)
  for _, extension_path in ipairs(extensions) do
    local extension = require(extension_path)
    extension.config(config)
  end
end

return M
