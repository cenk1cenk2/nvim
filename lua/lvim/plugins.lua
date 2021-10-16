return {
  -- Packer can manage itself as an optional plugin
  {'wbthomason/packer.nvim'},
  {'neovim/nvim-lspconfig'},
  {'tamago324/nlsp-settings.nvim'},
  {'jose-elias-alvarez/null-ls.nvim'},
  {'antoinemadec/FixCursorHold.nvim'}, -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  {'williamboman/nvim-lsp-installer'},

  {'nvim-lua/popup.nvim'},
  {'nvim-lua/plenary.nvim'},

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    config = function()
      require('lvim.core.telescope').setup()
    end,
    requires = {{'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}},
    disable = not lvim.builtin.telescope.active
  },

  {
    'folke/todo-comments.nvim',
    config = function()
      require('extensions.todo-comments').setup()
    end,
    disable = not lvim.extensions.todo_comments.active
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    'hrsh7th/nvim-cmp',
    config = function()
      require('lvim.core.cmp').setup()
    end,
    requires = {'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path', 'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-vsnip'},
    run = function()
      -- cmp's config requires cmp to be installed to run the first time
      if not lvim.builtin.cmp then require('lvim.core.cmp').config() end
    end
  },
  {
    'rafamadriz/friendly-snippets'
    -- event = "InsertCharPre",
    -- disable = not lvim.builtin.compe.active,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    -- event = "InsertEnter",
    after = 'nvim-cmp',
    config = function()
      require('lvim.core.autopairs').setup()
    end,
    disable = not lvim.builtin.autopairs.active
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require('lvim.core.treesitter').setup()
    end
  },

  {'nvim-treesitter/playground', requires = {'nvim-treesitter/nvim-treesitter'}},
  {'p00f/nvim-ts-rainbow', run = ':TSUpdate', requires = {'nvim-treesitter/nvim-treesitter'}},
  {'windwp/nvim-ts-autotag', requires = {'nvim-treesitter/nvim-treesitter'}},
  {'JoosepAlviste/nvim-ts-context-commentstring', requires = {'nvim-treesitter/nvim-treesitter'}},

  -- NvimTree
  {
    'kyazdani42/nvim-tree.lua',
    -- event = "BufWinOpen",
    -- cmd = "NvimTreeToggle",
    commit = 'edc74ee6c4aebdcbaea092557db372b93929f9d0',
    config = function()
      require('lvim.core.nvimtree').setup()
    end,
    disable = not lvim.builtin.nvimtree.active
  },

  {
    'lewis6991/gitsigns.nvim',

    config = function()
      require('lvim.core.gitsigns').setup()
    end,
    event = 'BufRead',
    disable = not lvim.builtin.gitsigns.active
  },

  -- Whichkey
  -- TODO: change back to folke/which-key.nvim after folke got back
  {
    'abzcoding/which-key.nvim',
    branch = 'fix/neovim-6-position',
    config = function()
      require('lvim.core.which-key').setup()
    end,
    event = 'BufWinEnter',
    disable = not lvim.builtin.which_key.active
  },

  -- Comments
  {
    'numToStr/Comment.nvim',
    event = 'BufRead',
    config = function()
      require('lvim.core.comment').setup()
    end,
    disable = not lvim.builtin.comment.active
  },

  -- project.nvim
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('lvim.core.project').setup()
    end,
    disable = not lvim.builtin.project.active
  },

  -- Icons
  {'kyazdani42/nvim-web-devicons'},

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    'shadmansaleh/lualine.nvim',
    -- "Lunarvim/lualine.nvim",
    config = function()
      require('lvim.core.lualine').setup()
    end,
    disable = not lvim.builtin.lualine.active
  },

  {
    'romgrk/barbar.nvim',
    config = function()
      require('lvim.core.bufferline').setup()
    end,
    event = 'BufWinEnter',
    disable = not lvim.builtin.bufferline.active
  },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    -- event = "BufWinEnter",
    config = function()
      require('lvim.core.dap').setup()
    end,
    disable = not lvim.builtin.dap.active
  },

  -- Debugger management
  {
    'Pocco81/DAPInstall.nvim',
    -- event = "BufWinEnter",
    -- event = "BufRead",
    disable = not lvim.builtin.dap.active
  },

  -- Dashboard
  {
    'ChristianChiarulli/dashboard-nvim',
    event = 'BufWinEnter',
    config = function()
      require('lvim.core.dashboard').setup()
    end,
    disable = not lvim.builtin.dashboard.active
  },

  -- Terminal
  {
    'akinsho/toggleterm.nvim',
    event = 'BufWinEnter',
    config = function()
      require('lvim.core.terminal').setup()
    end,
    disable = not lvim.builtin.terminal.active
  },

  -- Repeat last commands
  {
    'tpope/vim-repeat',
    config = function()
      require('extensions.vim-repeat').setup()
    end,
    disable = not lvim.extensions.vim_repeat.active
  },

  -- surround, change surround
  {
    'tpope/vim-surround',
    config = function()
      require('extensions.vim-surround').setup()
    end,
    disable = not lvim.extensions.vim_surround.active
  },

  -- smooth scroll
  {
    'karb94/neoscroll.nvim',
    event = 'BufWinEnter',
    config = function()
      require('extensions.neoscroll').setup()
    end,
    disable = not lvim.extensions.neoscroll.active
  },

  -- find and replace
  {
    'windwp/nvim-spectre',
    config = function()
      require('extensions.spectre').setup()
    end,
    disable = not lvim.extensions.spectre.active

  },

  -- multiple cursors
  {
    'mg979/vim-visual-multi',
    config = function()
      require('extensions.vim-visual-multi').setup()
    end,
    disable = not lvim.extensions.vim_visual_multi.active
  },

  -- ranger
  {
    'kevinhwang91/rnvimr',
    config = function()
      require('extensions.rnvimr').setup()
    end,
    disable = not lvim.extensions.rnvimr.active
  },

  -- maximize windows temporararily
  {
    'szw/vim-maximizer',
    config = function()
      require('extensions.vim-maximizer').setup()
    end,
    disable = not lvim.extensions.vim_maximizer.active
  },

  -- move windows with keybinds
  {
    'wesQ3/vim-windowswap',
    config = function()
      require('extensions.vim-windowswap').setup()
    end,
    disable = not lvim.extensions.vim_windowswap.active
  },

  -- whitespace control
  {
    'ntpeters/vim-better-whitespace',
    config = function()
      require('extensions.vim-better-whitespace').setup()
    end,
    disable = not lvim.extensions.vim_better_whitespace.active
  },

  -- undo-tree
  {
    'mbbill/undotree',
    config = function()
      require('extensions.undotree').setup()
    end,
    disable = not lvim.extensions.undotree.active
  },

  -- better quick fix window
  {
    'kevinhwang91/nvim-bqf',
    config = function()
      require('extensions.nvim-bqf').setup()
    end,
    disable = not lvim.extensions.nvim_bqf.active
  },

  -- lsp extensions
  {
    'folke/lsp-trouble.nvim',
    config = function()
      require('extensions.lsp-trouble').setup()
    end,
    disable = not lvim.extensions.lsp_trouble.active
  },

  {
    'simrat39/symbols-outline.nvim',
    config = function()
      require('extensions.symbols-outline').setup()
    end,
    disable = not lvim.extensions.symbols_outline.active
  },

  -- Colorized
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('extensions.colorizer').setup()
    end,
    disable = not lvim.extensions.colorizer.active
  },

  -- tab markers
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('extensions.indent-blankline').setup()
    end,
    disable = not lvim.extensions.indent_blankline.active
  }

}
