local M = {}

local extensions = {
  -- core
  "which-key",
  "alpha-nvim",
  "bufferline-nvim",
  "lualine-nvim",
  "telescope",
  "cmp",
  "cmp-extensions",
  "treesitter",
  "treesitter-extensions",
  "lsp",
  "mason",
  "toggleterm-nvim",
  "nvim-tree",
  "dap",
  "comment-nvim",
  "gitsigns-nvim",
  "nvim-autopairs",
  "project-nvim",
  "neovim-session-manager",
  "stickybuf-nvim",
  -- extensions
  "hop",
  "vim-repeat",
  "neoscroll",
  "spectre",
  "rnvimr",
  "vim-visual-multi",
  "windows-nvim",
  "vim-windowswap",
  "undotree",
  "nvim-ufo",
  "nvim-bqf",
  "lsp-trouble",
  "todo-comments",
  "indent-blankline",
  "octo",
  "diffview",
  "markdown-preview",
  "vim-bookmarks",
  "neogen",
  "coc",
  "lspsaga-nvim",
  "nvim-dap-ui",
  "nvim-dap-virtual-text",
  "vim-jinja2-syntax",
  "dressing",
  "aerojump-nvim",
  "nvim-hlslens",
  "nvim-scrollbar",
  "fidget-nvim",
  "vim-unconditionalpaste",
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
  "colorizer",
  "ccc-nvim",
  "vim-illuminate",
  "neotest",
  "lsp-inlayhints-nvim",
  "telescope-github",
  "telescope-vim-bookmarks",
  "telescope-dap",
  "nvim-trevJ",
  "symbols-outline",
  "aerial-nvim",
  "toggletasks-nvim",
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
