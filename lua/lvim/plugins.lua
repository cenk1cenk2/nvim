local commit = {
  barbar = "6e638309efcad2f308eb9c5eaccf6f62b794bbab",
  cmp_buffer = "f83773e2f433a923997c5faad7ea689ec24d1785",
  cmp_luasnip = "d6f837f4e8fe48eeae288e638691b91b97d1737f",
  cmp_nvim_lsp = "b4251f0fca1daeb6db5d60a23ca81507acf858c2",
  cmp_path = "4d58224e315426e5ac4c5b218ca86cab85f80c79",
  comment = "90df2f87c0b17193d073d1f72cea2e528e5b162d",
  dapinstall = "dd09e9dd3a6e29f02ac171515b8a089fb82bb425",
  dashboard_nvim = "d82ddae95fd4dc4c3b7bbe87f09b1840fbf20ecb",
  fixcursorhold = "0e4e22d21975da60b0fd2d302285b3b603f9f71e",
  friendly_snippets = "9f04462bcabfd108341a6e47ed742b09a6a5b975",
  gitsigns = "c18fc65c77abf95ac2e7783b9e7455a7a2fab26c",
  lua_dev = "03a44ec6a54b0a025a633978e8541584a02e46d9",
  lualine = "fd8fa5ddd823e15721ddec560ea61e7372e746a7",
  luasnip = "ed0140696fa99ea072bc485c87d22a396c477db3",
  nlsp_settings = "97125eeb68a412f11885dffe5fdcc3a26d36c58d",
  null_ls = "48ac5bcd4d766b371d91024d10c7c83fb909e388",
  nvim_autopairs = "5348e4a778ebdf42126a54fb5a933a98612df6cb",
  nvim_cmp = "9f6d2b42253dda8db950ab38795978e5420a93aa",
  nvim_dap = "3f1514d020f9d73a458ac04f42d27e5b284c0e48",
  nvim_lsp_installer = "2e81b1d86f90c8a05d7f875599818612bd68e1a7",
  nvim_lspconfig = "c7081e00fa8100ee099c16e375f3e5e838cbf1db",
  nvim_notify = "15f52efacd169ea26b0f4070451d3ea53f98cd5a",
  nvim_tree = "0a2f6b0b6ba558a88c77a6b262af647760e6eca8",
  nvim_treesitter = "a7c0c1764b0b583d0597108dd7d48bc5c0f98c81",
  nvim_ts_context_commentstring = "097df33c9ef5bbd3828105e4bee99965b758dc3f",
  nvim_web_devicons = "ac71ca88b1136e1ecb2aefef4948130f31aa40d1",
  packer = "851c62c5ecd3b5adc91665feda8f977e104162a5",
  plenary = "563d9f6d083f0514548f2ac4ad1888326d0a1c66",
  popup = "b7404d35d5d3548a82149238289fa71f7f6de4ac",
  project = "71d0e23dcfc43cfd6bb2a97dc5a7de1ab47a6538",
  structlog = "6f1403a192791ff1fa7ac845a73de9e860f781f1",
  telescope = "f06dd06bb1143caa779e492ca37e5f985f0c6157",
  telescope_fzf_native = "b8662b076175e75e6497c59f3e2799b879d7b954",
  toggleterm = "463843d1ba0288eedaf834872c3eca114d45bddf",
  which_key = "312c386ee0eafc925c27869d2be9c11ebdb807eb",
}

return {
  -- Packer can manage itself as an optional plugin
  { "wbthomason/packer.nvim" },
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
    disable = not lvim.builtin.notify.active,
    config = function()
      require("lvim.core.notify").setup()
    end,
    event = "BufRead",
  },
  { "Tastyep/structlog.nvim" },

  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require("lvim.core.telescope").setup()
    end,
    disable = not lvim.builtin.telescope.active,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    disable = not lvim.builtin.telescope.active,
    requires = "nvim-telescope/telescope.nvim",
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
    config = function()
      require("lvim.core.nvimtree").setup()
    end,
    disable = not lvim.builtin.nvimtree.active,
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
    -- "folke/which-key.nvim",
    -- commit = commit.which_key,
    "zeertzjq/which-key.nvim",
    branch = "patch-1",
    config = function()
      require("lvim.core.which-key").setup()
    end,
    event = "BufWinEnter",
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
    "ChristianChiarulli/dashboard-nvim",
    event = "BufWinEnter",
    config = function()
      require("lvim.core.dashboard").setup()
    end,
    disable = not lvim.builtin.dashboard.active,
  },
  {
    "goolord/alpha-nvim",
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

  -- language specific extension: rust
  {
    "simrat39/rust-tools.nvim",
    config = function()
      require("extensions.rust-tools-nvim").setup()
    end,
    disable = not lvim.extensions.rust_tools_nvim.active,
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
    "jbyuki/venn.nvim",
    config = function()
      require("extensions.venn-nvim").setup()
    end,
    disable = not lvim.extensions.venn_nvim.active,
  },

  {
    "ripxorip/aerojump.nvim",
    config = function()
      require("extensions.aerojump-nvim").setup()
    end,
    disable = not lvim.extensions.aerojump_nvim.active,
    run = ":UpdateRemotePlugins",
  },
}
