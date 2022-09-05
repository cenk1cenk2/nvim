local M = {}

local extensions = {
  "neotree-nvim",
  "alpha-nvim",
  "neovim-session-manager",
  "hop",
  "vim-repeat",
  "vim-surround",
  "neoscroll",
  "spectre",
  "rnvimr",
  "vim-better-whitespace",
  "vim-visual-multi",
  "vim-maximizer",
  "vim-windowswap",
  "undotree",
  "nvim-ufo",
  "cmp-extensions",
  "nvim-bqf",
  "lsp-trouble",
  "symbols-outline",
  "colorizer",
  "todo-comments",
  "indent-blankline",
  "vim-fugitive",
  "octo",
  "diffview",
  "vim-easy-align",
  "markdown-preview",
  "nvim-neoclip",
  "vim-bookmarks",
  "package-info",
  "neogen",
  "coc",
  "distant",
  "lspsaga-nvim",
  "nvim-dap-ui",
  "vim-jinja",
  "vim-jinja2-syntax",
  "nvim-orgmode",
  "dressing",
  "vim-caser",
  "aerojump-nvim",
  "nvim-hlslens",
  "nvim-scrollbar",
  "fidget-nvim",
  "vim-unconditionalpaste",
  "vim-unimpaired",
  "refactoring-nvim",
  "lsp-lines-nvim",
  "yanky-nvim",
  "cybu-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "tree-climber-nvim",
  "nvim-retrail",
  "nvim-surround",
  "cool-substitute-nvim",
  "align-nvim",
  "document-color-nvim",
  "vim-illuminate",
  "vgit-nvim",
  "git-conflict-nvim",
  "neotest",
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
