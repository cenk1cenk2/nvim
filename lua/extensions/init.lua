local M = {}

local extensions = {
  "alpha-nvim",
  "neovim-session-manager",
  "hop",
  "vim-repeat",
  "vim-surround",
  "neoscroll",
  "spectre",
  "rnvimr",
  "vim-visual-multi",
  "vim-maximizer",
  "vim-windowswap",
  "undotree",
  "nvim-ufo",
  "cmp-extensions",
  "nvim-bqf",
  "lsp-trouble",
  "colorizer",
  "todo-comments",
  "indent-blankline",
  "vim-fugitive",
  "octo",
  "diffview",
  "markdown-preview",
  "vim-bookmarks",
  "neogen",
  "coc",
  "lspsaga-nvim",
  "nvim-dap-ui",
  "vim-jinja2-syntax",
  "dressing",
  "aerojump-nvim",
  "nvim-hlslens",
  "nvim-scrollbar",
  "fidget-nvim",
  "vim-unconditionalpaste",
  "vim-unimpaired",
  "refactoring-nvim",
  "lsp-lines-nvim",
  "yanky-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "tree-climber-nvim",
  "nvim-retrail",
  "nvim-surround",
  "cool-substitute-nvim",
  "align-nvim",
  "document-color-nvim",
  "vim-illuminate",
  "git-conflict-nvim",
  "neotest",
  "lsp-inlayhints-nvim",
}

function M.config(config)
  local Log = require "lvim.core.log"

  for _, extension_path in ipairs(extensions) do
    local extension_ok, extension = pcall(require, "extensions." .. extension_path)
    if not extension_ok then
      Log:warn("Extension config can not be loaded: " .. extension_path)
    else
      extension.config(config)
    end
  end
end

return M
