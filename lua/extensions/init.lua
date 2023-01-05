local M = {}

local extensions = {
  "ui",
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
  "mason-nvim-dap",
  "toggleterm-nvim",
  "nvim-window-picker",
  "neotree-nvim",
  "dap",
  "comment-nvim",
  "gitsigns-nvim",
  "nvim-autopairs",
  "project-nvim",
  "neovim-session-manager",
  "stickybuf-nvim",
  "noice-nvim",
  "big-file-nvim",
  "no-neck-pain-nvim",
  -- extensions
  "hop",
  "vim-repeat",
  "neoscroll",
  "auto-hlsearch-nvim",
  "legendary-nvim",
  "spectre",
  "search-replace-nvim",
  "rnvimr",
  "vim-visual-multi",
  "vim-maximizer",
  "undotree",
  "telescope-undo-nvim",
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
  "nvim-hlslens",
  "nvim-scrollbar",
  "vim-unconditionalpaste",
  "refactoring-nvim",
  "lsp-lines-nvim",
  "yanky-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "tree-climber-nvim",
  "nvim-retrail",
  "nvim-surround",
  "document-color-nvim",
  "ccc-nvim",
  "vim-illuminate",
  "neotest",
  "lsp-inlayhints-nvim",
  "telescope-github",
  "telescope-vim-bookmarks",
  "telescope-dap",
  "nvim-trevJ",
  "treesj",
  "aerial-nvim",
  "nvim-docs-view",
  "mini-nvim-ai",
  "winshift-nvim",
  "exrc-nvim",
  "chatgpt-nvim",
  "browse-nvim",
}

function M.config(config)
  local Log = require("lvim.core.log")

  for _, extension_path in ipairs(extensions) do
    local extension_ok, extension = pcall(require, "extensions." .. extension_path)
    if not extension_ok then
      Log:warn(("Extension config can not be loaded: %s"):format(extension_path))
    else
      extension.config(config)
    end
  end
end

return M
