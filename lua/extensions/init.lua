local M = {}

local extensions = {
  "nvim-notify",
  "ui",
  -- core
  "which-key",
  "alpha-nvim",
  "bufferline-nvim",
  "mini-bufremove",
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
  "possession-nvim",
  "stickybuf-nvim",
  "noice-nvim",
  "nvim-lint",
  "conform-nvim",
  -- extensions
  "spider-nvim",
  "dap",
  "statuscol-nvim",
  "flash-nvim",
  "vim-repeat",
  "neoscroll",
  "auto-hlsearch-nvim",
  "spectre",
  "copilot-nvim",
  "aerial-nvim",
  "rgflow-nvim",
  "search-replace-nvim",
  "rnvimr",
  "vim-visual-multi",
  "nvim-treesitter-textobjects",
  "nvim-treesitter-context",
  "rainbow-delimiters-nvim",
  "nvim-recorder",
  "windows-nvim",
  "telescope-undo-nvim",
  "nvim-ufo",
  "nvim-bqf",
  "lsp-trouble",
  "nvim-lsp-file-operations",
  "todo-comments",
  "indent-blankline",
  "octo",
  "diffview",
  "github-preview-nvim",
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
  "lsp-timeout-nvim",
  "yanky-nvim",
  "substitute-nvim",
  "text-case-nvim",
  "nvim-retrail",
  "nvim-surround",
  "ccc-nvim",
  "nvim-colorizer",
  "vim-illuminate",
  "neotest",
  "telescope-github",
  "vim-bookmarks",
  "telescope-vim-bookmarks",
  "telescope-dap",
  "nvim-docs-view",
  "mini-nvim-ai",
  "mini-nvim-bracketed",
  "treesj",
  "winshift-nvim",
  "browse-nvim",
  "edgy-nvim",
  "typescript-tools-nvim",
  "yaml-companion-nvim",
  "uuid-nvim",
  "hurl-nvim",
  "dadbod",
  "git-worktree-nvim",
  "netman-nvim",
  "gitlab-nvim",
  "symbol-usage-nvim",
  "obsidian-nvim",
  "iswap-nvim",
  "iedit-nvim",
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
