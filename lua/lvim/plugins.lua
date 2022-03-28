local commit = {
  alpha_nvim = "8a0f62efbd94b00dd517efedeab1eb96fe544bd0",
  bufferline = "5e101b1b4e1ea5b868b8865a5f749b0b5b8f3ccd",
  cmp_buffer = "d66c4c2d376e5be99db68d2362cd94d250987525",
  cmp_luasnip = "d6f837f4e8fe48eeae288e638691b91b97d1737f",
  cmp_nvim_lsp = "ebdfc204afb87f15ce3d3d3f5df0b8181443b5ba",
  cmp_path = "466b6b8270f7ba89abd59f402c73f63c7331ff6e",
  comment = "a841f73523440c4f32d39f0290cf1e691311db2a",
  dapinstall = "24923c3819a450a772bb8f675926d530e829665f",
  fixcursorhold = "1bfb32e7ba1344925ad815cb0d7f901dbc0ff7c1",
  friendly_snippets = "ad07b2844021b20797adda5b483265802559a693",
  gitsigns = "2df360de757c39c04076cb04bcbbd361dec3c8c2",
  lua_dev = "a0ee77789d9948adce64d98700cc90cecaef88d5",
  lualine = "181b14348f513e6f9eb3bdd2252e13630094fdd3",
  luasnip = "ee350179f842699a42b3d6277b2ded8ce73bdc33",
  nlsp_settings = "ea9b88e289359843c3cc5bfbf42e5ed9cc3df5f2",
  null_ls = "041601cb03daa8982c5af6edc6641f4b97e9d6b5",
  nvim_autopairs = "6617498bea01c9c628406d7e23030da57f2f8718",
  nvim_cmp = "71d7f46b930bf08e982925c77bd9b0a9808c1162",
  nvim_dap = "3d0575a777610b364fea745b85ad497d56b8009a",
  nvim_lsp_installer = "dc783087bef65cc7c2943d8641ff1b6dfff6e5a9",
  nvim_lspconfig = "710deb04d9f8b73517e1d995a57a1505cbbaac51",
  nvim_notify = "f81b48d298c0ff7479b66568d9cc1a4794c196d0",
  nvim_tree = "20797a8d74e68bce50b98455c76c5de250c6f0e5",
  nvim_treesitter = "fd92e70c69330dd8f2f6753d3d987c34e7dacd24",
  nvim_ts_context_commentstring = "097df33c9ef5bbd3828105e4bee99965b758dc3f",
  nvim_web_devicons = "4415d1aaa56f73b9c05795af84d625c610b05d3b",
  onedarker = "b00dd2189f264c5aeb4cf04c59439655ecd573ec",
  packer = "c576ab3f1488ee86d60fd340d01ade08dcabd256",
  plenary = "14dfb4071022b22e08384ee125a5607464b6d397",
  popup = "b7404d35d5d3548a82149238289fa71f7f6de4ac",
  project = "cef52b8da07648b750d7f1e8fb93f12cb9482988",
  schemastore = "265eabf9f8ab33cc6bf1683c286b04e280a2b2e7",
  structlog = "6f1403a192791ff1fa7ac845a73de9e860f781f1",
  telescope = "a36a813d5d031e6f5d52b74986915e68130febd9",
  telescope_fzf_native = "8ec164b541327202e5e74f99bcc5fe5845720e18",
  toggleterm = "e97d0c1046512e975a9f3fa95afe98f312752b1c",
  which_key = "a3c19ec5754debb7bf38a8404e36a9287b282430",
}

return {
  -- Packer can manage itself as an optional plugin
  { "wbthomason/packer.nvim" },

  { "nvim-lua/plenary.nvim" },

  { "neovim/nvim-lspconfig" },
  { "tamago324/nlsp-settings.nvim" },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
  },
  {
    "williamboman/nvim-lsp-installer",
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      require("lvim.core.notify").setup()
    end,
    requires = { "nvim-telescope/telescope.nvim" },
    disable = not lvim.builtin.notify.active or not lvim.builtin.telescope.active,
  },
  { "nvim-lua/popup.nvim" },

  { "Tastyep/structlog.nvim" },

  -- Telescope
  {
    "kylo252/telescope.nvim",
    config = function()
      require("lvim.core.telescope").setup()
    end,
    branch = "nvim-nightly-compat",
    disable = not lvim.builtin.telescope.active,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    run = "make",
    commit = commit.telescope_fzf_native,
    disable = not lvim.builtin.telescope.active,
  },
  { "tzachar/fuzzy.nvim", requires = { "nvim-telescope/telescope-fzf-native.nvim" } },

  {
    "folke/todo-comments.nvim",
    config = function()
      require("extensions.todo-comments").setup()
    end,
    disable = not lvim.extensions.todo_comments.active,
  },
  {
    "nvim-telescope/telescope-github.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "gh"
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "tom-anders/telescope-vim-bookmarks.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require "telescope"
      telescope.load_extension "vim_bookmarks"

      local bookmark_actions = telescope.extensions.vim_bookmarks.actions
      telescope.extensions.vim_bookmarks.all {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }

      telescope.extensions.vim_bookmarks.current_file {
        attach_mappings = function(_, map)
          map("n", "dd", bookmark_actions.delete_selected_or_at_cursor)
          map("n", "D", bookmark_actions.delete_all)

          return true
        end,
      }
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "AckslD/nvim-neoclip.lua",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("extensions.nvim-neoclip").setup()
    end,
    disable = not lvim.builtin.telescope.active,
  },

  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("lvim.core.cmp").setup()
      require("extensions.cmp-extensions").setup()
    end,
    requires = {
      {
        "rafamadriz/friendly-snippets",
      },
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("luasnip/loaders/from_vscode").lazy_load()
        end,
      },
      {
        "saadparwaiz1/cmp_luasnip",
      },
      {
        "hrsh7th/cmp-buffer",
      },
      {
        "hrsh7th/cmp-nvim-lsp",
      },
      {
        "hrsh7th/cmp-path",
      },
      {
        "hrsh7th/cmp-nvim-lua",
      },

      "hrsh7th/cmp-vsnip",

      "petertriho/cmp-git",

      "David-Kunz/cmp-npm",

      "hrsh7th/cmp-cmdline",

      "davidsierradz/cmp-conventionalcommits",

      "tzachar/cmp-fuzzy-buffer",

      "lukas-reineke/cmp-rg",

      -- { "tzachar/cmp-tabnine", run = "./install.sh" },
    },
    run = function()
      -- cmp's config requires cmp to be installed to run the first time
      if lvim.builtin.cmp then
        require("lvim.core.cmp").setup()
      end
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
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
    branch = vim.fn.has "nvim-0.6" == 1 and "master" or "0.5-compat",
    -- run = ":TSUpdate",
    config = function()
      require("lvim.core.treesitter").setup()
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = "BufReadPost",
    requires = { "nvim-treesitter/nvim-treesitter" },
  },

  { "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "p00f/nvim-ts-rainbow", run = ":TSUpdate", requires = { "nvim-treesitter/nvim-treesitter" } },
  { "windwp/nvim-ts-autotag", requires = { "nvim-treesitter/nvim-treesitter" } },

  -- NvimTree
  {
    "kyazdani42/nvim-tree.lua",
    -- event = "BufWinOpen",
    -- cmd = "NvimTreeToggle",
    -- commit = commit.nvim_tree,
    config = function()
      require("lvim.core.nvimtree").setup()
    end,
    disable = not lvim.builtin.nvimtree.active,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("extensions.neotree-nvim").setup()
    end,
    branch = "v2.x",
    disable = not lvim.extensions.neotree_nvim.active,
    requires = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "lewis6991/gitsigns.nvim",

    config = function()
      require("lvim.core.gitsigns").setup()
    end,
    event = "BufRead",
    disable = not lvim.builtin.gitsigns.active,
  },

  -- Whichkey
  {
    "folke/which-key.nvim",
    config = function()
      require("lvim.core.which-key").setup()
    end,
    disable = not lvim.builtin.which_key.active,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("lvim.core.comment").setup()
    end,
    disable = not lvim.builtin.comment.active,
  },

  -- project.nvim
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("lvim.core.project").setup()
    end,
    disable = not lvim.builtin.project.active,
  },

  -- Icons
  { "kyazdani42/nvim-web-devicons" },

  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    -- "Lunarvim/lualine.nvim",
    config = function()
      require("lvim.core.lualine").setup()
    end,
    disable = not lvim.builtin.lualine.active,
  },

  {
    "romgrk/barbar.nvim",
    config = function()
      require("lvim.core.bufferline").setup()
    end,
    event = "BufWinEnter",
    disable = not lvim.builtin.bufferline.active,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
    -- event = "BufWinEnter",
    config = function()
      require("lvim.core.dap").setup()
    end,
    disable = not lvim.builtin.dap.active,
  },

  -- Debugger management
  {
    "Pocco81/DAPInstall.nvim",
    -- event = "BufWinEnter",
    -- event = "BufRead",
    disable = not lvim.builtin.dap.active,
  },

  { "rcarriga/nvim-dap-ui", disable = not lvim.builtin.dap.active, requires = { "mfussenegger/nvim-dap" } },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    commit = commit.alpha_nvim,
    event = "BufWinEnter",
    config = function()
      require("extensions.alpha-nvim").setup()
    end,
    disable = not lvim.extensions.alpha.active,
  },

  -- Session Manager
  {
    "Shatur/neovim-session-manager",
    config = function()
      require("extensions.neovim-session-manager").setup()
    end,
    disable = not lvim.extensions.session_manager.active,
  },

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
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

  -- search highlighting
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("extensions.nvim-hlslens").setup()
    end,
    disable = not lvim.extensions.nvim_hlslens.active,
  },

  -- scrollbar
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("extensions.nvim-scrollbar").setup()
    end,
    disable = not lvim.extensions.nvim_scrollbar.active,
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
    "cenk1cenk2/nvim-spectre",
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

  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("extensions.lsp-lines-nvim").setup()
    end,
    disable = not lvim.extensions.lsp_lines_nvim.active,
  },

  -- lsp loader information
  {
    "j-hui/fidget.nvim",
    config = function()
      require("extensions.fidget-nvim").setup()
    end,
    disable = not lvim.extensions.fidget_nvim.active,
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
    branch = "fix/118",
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

  {
    "stevearc/dressing.nvim",
    config = function()
      require("extensions.dressing").setup()
    end,
    disable = not lvim.extensions.dressing.active,
  },

  {
    "arthurxavierx/vim-caser",
    config = function()
      require("extensions.vim-caser").setup()
    end,
    disable = not lvim.extensions.vim_caser.active,
  },

  {
    "nvim-orgmode/orgmode",
    config = function()
      require("extensions.nvim-orgmode").setup()
    end,
    disable = not lvim.extensions.orgmode.active,
  },

  {
    "ripxorip/aerojump.nvim",
    config = function()
      require("extensions.aerojump-nvim").setup()
    end,
    disable = not lvim.extensions.aerojump_nvim.active,
    run = ":UpdateRemotePlugins",
  },

  {
    "inkarkat/vim-UnconditionalPaste",
    config = function()
      require("extensions.vim-unconditionalpaste").setup()
    end,
    disable = not lvim.extensions.vim_unconditionalpaste.active,
  },

  {
    "tpope/vim-unimpaired",
    config = function()
      require("extensions.vim-unimpaired").setup()
    end,
    disable = not lvim.extensions.vim_unimpaired.active,

    -- SchemaStore
    {
      "b0o/schemastore.nvim",
    },
  },

  {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require("extensions.refactoring-nvim").setup()
    end,
    disable = not lvim.extensions.refactoring_nvim.active,
  },
}
