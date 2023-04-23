local M = {}

local extensions = {
  "nvim-notify",
  "ui",
  -- core
  "which-key",
  "alpha-nvim",
  "bufferline-nvim",
  "lualine-nvim",
  "telescope",
  "cmp",
  "treesitter",
  "lsp",
  "mason",
  "mason-nvim-dap",
  "toggleterm-nvim",
  "flatten-nvim",
  "nvim-window-picker",
  "neotree-nvim",
  "comment-nvim",
  "gitsigns-nvim",
  "nvim-autopairs",
  "project-nvim",
  "neovim-session-manager",
  "stickybuf-nvim",
  "noice-nvim",
  -- extensions
  "dap",
  "no-neck-pain-nvim",
  "statuscol-nvim",
  "hop",
  "vim-repeat",
  "neoscroll",
  "auto-hlsearch-nvim",
  "spectre",
  "search-replace-nvim",
  "rnvimr",
  "vim-visual-multi",
  "nvim-recorder",
  "neocomposer-nvim",
  "windows-nvim",
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
  "gitignore-nvim",
  "lspsaga-nvim",
  "nvim-dap-ui",
  "nvim-dap-virtual-text",
  "vim-jinja2-syntax",
  "dressing",
  "nvim-hlslens",
  "nvim-scrollbar",
  "refactoring-nvim",
  "lsp-lines-nvim",
  "yanky-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "tree-climber-nvim",
  "nvim-retrail",
  "nvim-surround",
  "ccc-nvim",
  "nvim-colorizer",
  "vim-illuminate",
  "neotest",
  "lsp-inlayhints-nvim",
  "telescope-github",
  "telescope-vim-bookmarks",
  "telescope-dap",
  "aerial-nvim",
  "nvim-navbuddy",
  "nvim-docs-view",
  "mini-nvim-ai",
  "mini-nvim-bracketed",
  "treesj",
  "winshift-nvim",
  "exrc-nvim",
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
