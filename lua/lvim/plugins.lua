local commit = {
  packer = "7f62848f3a92eac61ae61def5f59ddb5e2cc6823",
  lsp_config = "903a1fbca91b74e6fbc905366ce38364b9d7ba98",
  nlsp_settings = "29f49afe27b43126d45a05baf3161a28b929f2f1",
  null_ls = "cf2bc3185af066cb25f1bf6faa99727e2c47ef77",
  fix_cursor_hold = "0e4e22d21975da60b0fd2d302285b3b603f9f71e",
  lsp_installer = "37d9326f4ca4093b04eabdb697fec3764e226f88",
  nvim_notify = "ee79a5e2f8bde0ebdf99880a98d1312da83a3caa",
  structlog = "6f1403a192791ff1fa7ac845a73de9e860f781f1",
  popup = "f91d80973f80025d4ed00380f2e06c669dfda49d",
  plenary = "96e821e8001c21bc904d3c15aa96a70c11462c5f",
  telescope = "078a48db9e0720b07bfcb8b59342c5305a1d1fdc",
  telescope_fzf_native = "59e38e1661ffdd586cb7fc22ca0b5a05c7caf988",
  nvim_cmp = "ca6386854982199a532150cf3bd711395475ebd2",
  friendly_snippets = "94f1d917435c71bc6494d257afa90d4c9449aed2",
  autopairs = "f858ab38b532715dbaf7b2773727f8622ba04322",
  treesitter = "47cfda2c6711077625c90902d7722238a8294982",
  context_commentstring = "159c5b9a2cdb8a8fe342078b7ac8139de76bad62",
  nvim_tree = "f92b7e7627c5a36f4af6814c408211539882c4f3",
  gitsigns = "61a81b0c003de3e12555a5626d66fb6a060d8aca",
  which_key = "d3032b6d3e0adb667975170f626cb693bfc66baa",
  comment = "620445b87a0d1640fac6991f9c3338af8dec1884",
  project = "3a1f75b18f214064515ffba48d1eb7403364cc6a",
  nvim_web_devicons = "ee101462d127ed6a5561ce9ce92bfded87d7d478",
  lualine = "3f5cdc51a08c437c7705e283eebd4cf9fbb18f80",
  barbar = "6e638309efcad2f308eb9c5eaccf6f62b794bbab",
  dap = "dd778f65dc95323f781f291fb7c5bf3c17d057b1",
  dap_install = "dd09e9dd3a6e29f02ac171515b8a089fb82bb425",
  toggleterm = "5f9ba91157a25be5ee7395fbc11b1a8f25938365",
  luasnip = "bab7cc2c32fba00776d2f2fc4704bed4eee2d082",
  cmp_luasnip = "16832bb50e760223a403ffa3042859845dd9ef9d",
  cmp_buffer = "d1ca295ce584ec80763a6dc043080874b57ccffc",
  cmp_nvim_lsp = "accbe6d97548d8d3471c04d512d36fa61d0e4be8",
  cmp_path = "97661b00232a2fe145fe48e295875bc3299ed1f7",
  cmp_nvim_lua = "d276254e7198ab7d00f117e88e223b4bd8c02d21",
}

return {
  -- Packer can manage itself as an optional plugin
  { "wbthomason/packer.nvim", commit = commit.packer },
  { "neovim/nvim-lspconfig", commit = commit.lsp_config },
  { "tamago324/nlsp-settings.nvim", commit = commit.nlsp_settings },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
  },
  {
    "williamboman/nvim-lsp-installer",
    commit = commit.lsp_installer,
  },
  {
    "rcarriga/nvim-notify",
    commit = commit.nvim_notify,
    disable = not lvim.builtin.notify.active,
  },
  { "Tastyep/structlog.nvim", commit = commit.structlog },

  { "nvim-lua/popup.nvim", commit = commit.popup },
  { "nvim-lua/plenary.nvim", commit = commit.plenary },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    commit = commit.telescope,
    config = function()
      require("lvim.core.telescope").setup()
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    commit = commit.telescope_fzf_native,
    run = "make",
    disable = not lvim.builtin.telescope.active,
    requires = "nvim-telescope/telescope.nvim",
  },

  {
    "folke/todo-comments.nvim",
    config = function()
      require("extensions.todo-comments").setup()
    end,
    disable = not lvim.extensions.todo_comments.active,
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    commit = commit.nvim_cmp,
    config = function()
      require("lvim.core.cmp").setup()
      require("extensions.cmp-extensions").setup()
    end,
    requires = {

      {
        "rafamadriz/friendly-snippets",
        commit = commit.friendly_snippets,
        -- event = "InsertCharPre",
        -- disable = not lvim.builtin.compe.active,
      },
      {
        "L3MON4D3/LuaSnip",
        commit = commit.luasnip,
      },
      {
        "saadparwaiz1/cmp_luasnip",
        commit = commit.cmp_luasnip,
      },
      {
        "hrsh7th/cmp-buffer",
        commit = commit.cmp_buffer,
      },
      {
        "hrsh7th/cmp-nvim-lsp",
        commit = commit.cmp_nvim_lsp,
      },
      {
        "hrsh7th/cmp-path",
        commit = commit.cmp_path,
      },
      {
        "hrsh7th/cmp-nvim-lua",
        commit = commit.cmp_nvim_lua,
      },

      "hrsh7th/cmp-vsnip",

      "petertriho/cmp-git",

      "David-Kunz/cmp-npm",

      "hrsh7th/cmp-cmdline",
    },
    run = function()
      -- cmp's config requires cmp to be installed to run the first time
      if not lvim.builtin.cmp then
        require("lvim.core.cmp").config()
      end
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    commit = commit.autopairs,
    -- event = "InsertEnter",
    after = "nvim-cmp",
    config = function()
      require("lvim.core.autopairs").setup()
    end,
    disable = not lvim.builtin.autopairs.active,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    commit = commit.treesitter,
    branch = "0.5-compat",
    config = function()
      require("lvim.core.treesitter").setup()
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "BufReadPost",
    commit = commit.context_commentstring,
    requires = { "nvim-treesitter/nvim-treesitter" },
  },

  { "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "p00f/nvim-ts-rainbow", run = ":TSUpdate", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "windwp/nvim-ts-autotag", requires = { "nvim-treesitter/nvim-treesitter" } },
  {
    "nvim-telescope/telescope-github.nvim",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("telescope").load_extension "gh"
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    requires = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("extensions.nvim-neoclip").setup()
    end,
  },

  -- NvimTree
  {
    "kyazdani42/nvim-tree.lua",
    -- event = "BufWinOpen",
    -- cmd = "NvimTreeToggle",
    commit = commit.nvim_tree,
    config = function()
      require("lvim.core.nvimtree").setup()
    end,
    disable = not lvim.builtin.nvimtree.active,
  },

  {
    "lewis6991/gitsigns.nvim",
    commit = commit.gitsigns,

    config = function()
      require("lvim.core.gitsigns").setup()
    end,
    event = "BufRead",
    disable = not lvim.builtin.gitsigns.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    commit = commit.which_key,
    config = function()
      require("lvim.core.which-key").setup()
    end,
    event = "BufWinEnter",
    disable = not lvim.builtin.which_key.active,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    commit = commit.comment,
    event = "BufRead",
    config = function()
      require("lvim.core.comment").setup()
    end,
    disable = not lvim.builtin.comment.active,
  },

  -- project.nvim
  {
    "ahmedkhalf/project.nvim",
    commit = commit.project,
    config = function()
      require("lvim.core.project").setup()
    end,
    disable = not lvim.builtin.project.active,
  },

  -- Icons
  { "kyazdani42/nvim-web-devicons", commit = commit.nvim_web_devicons },

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    commit = commit.lualine,
    -- "Lunarvim/lualine.nvim",
    config = function()
      require("lvim.core.lualine").setup()
    end,
    disable = not lvim.builtin.lualine.active,
  },

  {
    "romgrk/barbar.nvim",
    commit = commit.barbar,
    config = function()
      require("lvim.core.bufferline").setup()
    end,
    event = "BufWinEnter",
    disable = not lvim.builtin.bufferline.active,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    commit = commit.dap,
    -- event = "BufWinEnter",
    config = function()
      require("lvim.core.dap").setup()
    end,
    disable = not lvim.builtin.dap.active,
  },

  -- Debugger management
  {
    "Pocco81/DAPInstall.nvim",
    commit = commit.dap_install,
    -- event = "BufWinEnter",
    -- event = "BufRead",
    disable = not lvim.builtin.dap.active,
  },

  { "rcarriga/nvim-dap-ui", disable = not lvim.builtin.dap.active, requires = { "mfussenegger/nvim-dap" } },

  -- Dashboard
  {
    "ChristianChiarulli/dashboard-nvim",
    event = "BufWinEnter",
    config = function()
      require("lvim.core.dashboard").setup()
    end,
    disable = not lvim.builtin.dashboard.active,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    commit = commit.toggleterm,
    event = "BufWinEnter",
    config = function()
      require("lvim.core.terminal").setup()
    end,
    disable = not lvim.builtin.terminal.active,
  },

  -- hop
  {
    "phaazon/hop.nvim",
    config = function()
      require("extensions.hop").setup()
    end,
    disable = not lvim.extensions.hop.active,
  },

  -- Repeat last commands
  {
    "tpope/vim-repeat",
    config = function()
      require("extensions.vim-repeat").setup()
    end,
    disable = not lvim.extensions.vim_repeat.active,
  },

  -- surround, change surround
  {
    "tpope/vim-surround",
    config = function()
      require("extensions.vim-surround").setup()
    end,
    disable = not lvim.extensions.vim_surround.active,
  },

  -- smooth scroll
  {
    "karb94/neoscroll.nvim",
    event = "BufWinEnter",
    config = function()
      require("extensions.neoscroll").setup()
    end,
    disable = not lvim.extensions.neoscroll.active,
  },

  -- find and replace
  {
    "windwp/nvim-spectre",
    config = function()
      require("extensions.spectre").setup()
    end,
    disable = not lvim.extensions.spectre.active,
  },

  -- multiple cursors
  {
    "mg979/vim-visual-multi",
    config = function()
      require("extensions.vim-visual-multi").setup()
    end,
    disable = not lvim.extensions.vim_visual_multi.active,
  },

  -- ranger
  {
    "kevinhwang91/rnvimr",
    config = function()
      require("extensions.rnvimr").setup()
    end,
    disable = not lvim.extensions.rnvimr.active,
  },

  -- maximize windows temporararily
  {
    "szw/vim-maximizer",
    config = function()
      require("extensions.vim-maximizer").setup()
    end,
    disable = not lvim.extensions.vim_maximizer.active,
  },

  -- move windows with keybinds
  {
    "wesQ3/vim-windowswap",
    config = function()
      require("extensions.vim-windowswap").setup()
    end,
    disable = not lvim.extensions.vim_windowswap.active,
  },

  -- whitespace control
  {
    "ntpeters/vim-better-whitespace",
    config = function()
      require("extensions.vim-better-whitespace").setup()
    end,
    disable = not lvim.extensions.vim_better_whitespace.active,
  },

  -- undo-tree
  {
    "mbbill/undotree",
    config = function()
      require("extensions.undotree").setup()
    end,
    disable = not lvim.extensions.undotree.active,
  },

  -- better quick fix window
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      require("extensions.nvim-bqf").setup()
    end,
    disable = not lvim.extensions.nvim_bqf.active,
  },

  -- lsp extensions
  {
    "folke/lsp-trouble.nvim",
    config = function()
      require("extensions.lsp-trouble").setup()
    end,
    disable = not lvim.extensions.lsp_trouble.active,
  },

  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("extensions.symbols-outline").setup()
    end,
    disable = not lvim.extensions.symbols_outline.active,
  },

  -- Colorized
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("extensions.colorizer").setup()
    end,
    disable = not lvim.extensions.colorizer.active,
  },

  -- tab markers
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("extensions.indent-blankline").setup()
    end,
    disable = not lvim.extensions.indent_blankline.active,
  },

  -- git related
  {
    "tpope/vim-fugitive",
    config = function()
      require("extensions.vim-fugitive").setup()
    end,
    disable = not lvim.extensions.vim_fugitive.active,
  },

  {
    "pwntester/octo.nvim",
    config = function()
      require("extensions.octo").setup()
    end,
    disable = not lvim.extensions.octo.active,
  },

  {
    "sindrets/diffview.nvim",
    config = function()
      require("extensions.diffview").setup()
    end,
    disable = not lvim.extensions.diffview.active,
  },

  -- coc
  {
    "neoclide/coc.nvim",
    branch = "release",
    config = function()
      require("extensions.coc").setup()
    end,
    disable = not lvim.extensions.coc.active,
  },

  -- easy align
  {
    "junegunn/vim-easy-align",
    config = function()
      require("extensions.vim-easy-align").setup()
    end,
    disable = not lvim.extensions.vim_easy_align.active,
  },

  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    run = { "cd app & yarn & yarn add -D tslib", ":call mkdp#util#install()" },
    config = function()
      require("extensions.markdown-preview").setup()
    end,
    disable = not lvim.extensions.markdown_preview.active,
  },

  {
    "MattesGroeger/vim-bookmarks",
    config = function()
      require("extensions.vim-bookmarks").setup()
    end,
    disable = not lvim.extensions.vim_bookmarks.active,
  },

  {
    "vuki656/package-info.nvim",
    requires = "MunifTanjim/nui.nvim",
    config = function()
      require("extensions.package-info").setup()
    end,
    disable = not lvim.extensions.package_info.active,
  },

  {
    "danymat/neogen",
    config = function()
      require("extensions.neogen").setup()
    end,
    requires = { "nvim-treesitter/nvim-treesitter" },
    disable = not lvim.extensions.neogen.active,
  },

  {
    "chipsenkbeil/distant.nvim",
    config = function()
      require("extensions.distant").setup()
    end,
    disable = not lvim.extensions.distant.active,
  },

  {
    "lepture/vim-jinja",
    config = function()
      require("extensions.vim-jinja").setup()
    end,
    disable = not lvim.extensions.vim_jinja.active,
  },
}
