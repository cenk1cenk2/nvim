local M = {}

M.mappings = {
  ["="] = { "<C-W>=<CR>", "balance open windows" },
  ["x"] = { "<C-W>s", "split below" },
  ["v"] = { "<C-W>v", "split right" },
  ["n"] = { ":nohlsearch<CR>", "no highlight" },
  ["p"] = {
    function()
      require("lvim.core.telescope.custom-finders").find_project_files()
    end,
    "find file",
  },
  ["q"] = {
    function()
      lvim.lsp_wrapper.fix_current()
    end,
    "fix current",
  },

  -- actions
  a = {
    name = "+actions",
    c = { ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>", "bring back cursor" },
    d = { ":! ansible-vault decrypt %:p<CR>", "ansible-vault decrypt" },
    D = { ":! ansible-vault encrypt %:p<CR>", "ansible-vault encrypt" },
    e = { ":set ff=unix<CR>", "set lf" },
    E = { ":set ff=dos<CR>", "set crlf" },
    f = { ":Telescope filetypes<CR>", "select from filetypes" },
    l = { ":set nonumber!<CR>", "toggle line numbers" },
    r = { ":set norelativenumber!<CR>", "toggle relative line numbers" },
    s = { ":setlocal spell!<CR>", "toggle spell check" },
    t = {
      ":RunMarkdownToc<CR>",
      "markdown-toc",
    },
    P = {
      ":RunMdPrinter<CR>",
      "md-printer",
    },
  },

  -- buffer
  b = {
    name = "+buffer",
    d = { ":BufferKill<CR>", "delete buffer" },
    e = { ":e<CR>", "reopen current buffer" },
    E = { ":e!<CR>", "force reopen current buffer" },
    f = { ":Telescope buffers<CR>", "find buffer" },
    s = { ":edit #<CR>", "switch to last buffer" },
    S = { ":w!<CR>:lua require('lvim.core.log'):warn('File overwritten.')<CR>", "overwrite - force save" },
  },

  -- find
  f = {
    name = "+search",
    A = { ":Telescope builtin<CR>", "telescope list builtin finders" },
    b = { ":Telescope current_buffer_fuzzy_find<CR>", "search current buffer" },
    f = { ":Telescope oldfiles<CR>", "search file history" },
    ["."] = { ":Telescope commands<CR>", "search available commands" },
    [":"] = { ":Telescope command_history<CR>", "search command history" },
    g = { ":Telescope grep_string<CR>", "grep string under cursor" },
    m = { ":Telescope vim_bookmarks all<CR>", "list all bookmarks" },
    M = { ":Telescope vim_bookmarks current_file<CR>", "list document bookmarks" },
    j = { ":Telescope jumplist<CR>", "list jumps" },
    k = { ":Telescope keymaps<CR>", "list keymaps" },
    s = { ":Telescope spell_suggest<CR>", "spell suggest" },
    r = {
      function()
        require("modules.telescope").rg_interactive()
      end,
      "ripgrep interactive",
    },
    d = {
      function()
        require("modules.telescope").rg_dirty()
      end,
      "dirty fuzzy grep",
    },
    p = { ":Telescope find_files<CR>", "find file" },
    R = { ":Telescope registers<CR>", "list registers" },
    t = {
      function()
        require("modules.telescope").rg_string()
      end,
      "grep string",
    },
    T = { ":Telescope live_grep<CR>", "grep with regexp" },
    O = { ":Telescope vim_options<CR>", "list vim options" },
  },

  -- find and replace
  s = {
    name = "+find & replace",
    f = { ":FindAndReplace<CR>", "find and replace" },
    s = { ":FindAndReplaceVisual<CR>", "find the word under cursor and replace" },
    b = { ":FindAndReplaceInBuffer<CR>", "find and replace in current buffer" },
  },

  -- git
  g = {
    name = "+git",
    A = { ":0Gclog<CR>", "buffer commits" },
    B = { ":Git blame<CR>", "git blame" },
    C = { ":Gdiffsplit<CR>", "diff split" },
    e = { ":Gedit<CR>", "edit version" },
    f = { ":Telescope git_files<CR>", "list git tracked files" },
    n = { ":Gitsigns next_hunk<CR>", "next hunk" },
    p = { ":Gitsigns prev_hunk<CR>", "prev hunk" },
    b = { ":Gitsigns blame_line<CR>", "git hover blame" },
    k = { ":Gitsigns preview_hunk<CR>", "preview hunk" },
    U = { ":Gitsigns reset_hunk<CR>", "reset hunk" },
    R = { ":Gitsigns reset_buffer<CR>", "reset buffer" },
    s = { ":Gitsigns stage_hunk<CR>", "stage hunk" },
    S = { ":Gitsigns undo_stage_hunk<CR>", "undo stage hunk" },
    m = { ":Gvdiffsplit!<CR>", "merge view, 3-way-split" },
    o = { ":Telescope git_status<CR>", "open git status" },
  },

  -- gist
  G = {
    name = "+gist",
    f = { ":CocList gist<CR>", "list gists" },
    i = { ":CocList gitignore<CR>", "generate git ignore" },
    p = { ":CocCommand gist.create<CR>", "post new gist" },
    I = { ":Telescope gh issues<CR>", "github issues" },
    P = { ":Telescope gh pull_request<CR>", "github pull requests" },
    U = { ":CocCommand gist.update<CR>", "update current gist" },
  },

  -- lsp
  l = {
    name = "LSP",
    d = {
      function()
        lvim.lsp_wrapper.document_diagnostics()
      end,
      "document diagnostics",
    },
    D = {
      function()
        lvim.lsp_wrapper.workspace_diagnostics()
      end,
      "workspace diagnostics",
    },
    f = {
      function()
        lvim.lsp_wrapper.format()
      end,
      "format buffer",
    },
    F = { ":LvimToggleFormatOnSave<CR>", "toggle autoformat" },
    g = { ":LspOrganizeImports<CR>", "organize imports" },
    i = {
      ":lua require('lvim.core.info').toggle_popup(vim.bo.filetype)<CR>",
      "Toggle LunarVim Info",
    },
    I = { ":LspInstallInfo<CR>", "lsp installer info" },
    m = { ":LspRenameFile<CR>", "rename with lsp" },
    h = { ":LspImportAll<CR>", "import all missing" },
    H = { ":LspImportCurrent<CR>", "import current" },
    n = {
      function()
        lvim.lsp_wrapper.goto_next()
      end,
      "next diagnostic",
    },
    p = {
      function()
        lvim.lsp_wrapper.goto_prev()
      end,
      "prev diagnostic",
    },
    l = {
      function()
        lvim.lsp_wrapper.code_lens()
      end,
      "codelens",
    },
    R = {
      function()
        lvim.lsp_wrapper.rename()
      end,
      "rename item under cursor",
    },
    q = {
      function()
        lvim.lsp_wrapper.diagonistics_set_list()
      end,
      "set quickfix list",
    },
    s = {
      function()
        lvim.lsp_wrapper.document_symbols()
      end,
      "document symbols",
    },
    S = {
      function()
        lvim.lsp_wrapper.workspace_symbols()
      end,
      "workspace symbols",
    },
    Q = { ":LspRestart<CR>", "restart currently active lsps" },
  },

  -- terminal
  t = {
    name = "+terminal",
    f = { ":Telescope find_terminals list<CR>", "list terminals" },
  },

  -- workspace/session
  w = {
    name = "+Session",
    c = { ":Alpha<CR>", "dashboard" },
    q = { ":lua require('lvim.utils.functions').smart_quit()<CR>", "quit" },
    d = { ":SessionManager delete_session<CR>", "delete sessions" },
    l = { ":SessionManager load_current_dir_session<CR>", "load cwd last session" },
    L = { ":SessionManager load_last_session<CR>", "load last session" },
    s = { ":SessionManager save_current_session<CR>", "save session" },
    f = { ":SessionManager load_session<CR>", "list sessions" },
    p = { ":Telescope projects<CR>", "projects" },
  },

  L = {
    name = "+LunarVim",
    c = {
      ":edit " .. get_config_dir() .. "/config.lua<CR>",
      "Edit config.lua",
    },
    f = {
      ":lua require('lvim.core.telescope.custom-finders').find_lunarvim_files()<CR>",
      "Find LunarVim files",
    },
    g = {
      ":lua require('lvim.core.telescope.custom-finders').grep_lunarvim_files()<CR>",
      "Grep LunarVim files",
    },
    k = { ":Telescope keymaps<CR>", "View LunarVim's keymappings" },
    i = {
      ":lua require('lvim.core.info').toggle_popup(vim.bo.filetype)<CR>",
      "Toggle LunarVim Info",
    },
    I = {
      ":lua require('lvim.core.telescope.custom-finders').view_lunarvim_changelog()<CR>",
      "View LunarVim's changelog",
    },
    l = {
      name = "+logs",
      d = {
        ":lua require('lvim.core.terminal').toggle_log_view(require('lvim.core.log').get_path())<CR>",
        "view default log",
      },
      D = {
        ":lua vim.fn.execute('edit ' .. require('lvim.core.log').get_path())<CR>",
        "Open the default logfile",
      },
      l = {
        ":lua require('lvim.core.terminal').toggle_log_view(vim.lsp.get_log_path())<CR>",
        "view lsp log",
      },
      L = { ":lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<CR>", "Open the LSP logfile" },
      n = {
        ":lua require('lvim.core.terminal').toggle_log_view(os.getenv('NVIM_LOG_FILE'))<CR>",
        "view neovim log",
      },
      N = { ":edit $NVIM_LOG_FILE<CR>", "Open the Neovim logfile" },
      p = {
        ":lua require('lvim.core.terminal').toggle_log_view('packer.nvim')<CR>",
        "view packer log",
      },
      P = { ":exe 'edit '.stdpath('cache').'/packer.nvim.log'<CR>", "Open the Packer logfile" },
    },
    r = { ":LvimReload<CR>", "Reload LunarVim's configuration" },
    u = { ":LvimUpdate<CR>", "Update LunarVim" },
  },

  P = {
    name = "Packer",
    c = { ":PackerCompile<CR>", "packer compile" },
    i = { ":PackerInstall<CR>", "packer install" },
    r = { ":lua require('lvim.plugin-loader').recompile()<CR>", "packer re-compile" },
    s = { ":PackerSync<CR>", "packer sync" },
    S = { ":PackerStatus<CR>", "packer status" },
    u = { ":PackerUpdate<CR>", "packer update" },
  },

  T = {
    name = "Treesitter",
    i = { ":TSConfigInfo<CR>", "treesitter info" },
    k = { ":TSHighlightCapturesUnderCursor<CR>", "show treesitter theme color" },
    u = { ":TSUpdate<CR>", "update installed treesitter packages" },
    U = { ":TSUninstall all<CR>", "uninstall all treesitter packages" },
    R = { ":TSInstall all<CR>", "reinstall all treesitter packages" },
  },

  R = {
    name = "Tasks",
    r = {
      function()
        require("modules.nvim").rebuild_latest_neovim()
      end,
      "install latest neovim",
    },
    u = {
      function()
        require("modules.nvim").rebuild_and_update()
      end,
      "rebuild and update everything",
    },
  },
}

M.vmappings = {
  ["="] = M.mappings["="],
  ["x"] = M.mappings["x"],
  ["v"] = M.mappings["v"],
  ["n"] = M.mappings["n"],
  ["p"] = M.mappings["p"],
}

return M
