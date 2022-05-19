local M = {}

M.vmappings = {}

M.mappings = {
  ["="] = { "<C-W>=<CR>", "balance open windows" },
  ["h"] = { "<C-W>s", "split below" },
  ["v"] = { "<C-W>v", "split right" },
  ["n"] = { ":nohlsearch<CR>", "no highlight" },
  ["p"] = { require("lvim.core.telescope.custom-finders").find_project_files, "find file" },
  ["q"] = { ":LspFixCurrent<CR>", "quick fix" },

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
      ":! md-printer %<CR>",
      "md-printer",
    },
    R = {
      ":RebuildLatestNeovim<CR>",
      "install latest neovim",
    },
    T = {
      ":LspInstallerReinstallAll<CR>",
      "reinstall all language servers",
    },
    Z = {
      ":RebuildAndUpdate<CR>",
      "rebuild and update everything",
    },
  },

  -- buffer
  b = {
    name = "+buffer",
    b = { ":BufferPick<CR>", "pick buffer" },
    d = { ":Bdelete<CR>", "delete buffer" },
    C = { ":BufferWipeout<CR>", "close all buffers" },
    e = { ":e<CR>", "reopen current buffer" },
    E = { ":e!<CR>", "force reopen current buffer" },
    f = { ":Telescope buffers<CR>", "find buffer" },
    x = { ":BufferClose!<CR>", "force close buffer" },
    X = { ":BufferCloseAllButCurrent<CR>", "close all but current buffer" },
    p = { ":BufferPin<CR>", "pin current buffer" },
    P = { ":BufferCloseAllButPinned<CR>", "close all but pinned buffers" },
    s = { ":edit #<CR>", "switch to last buffer" },
    S = { ":w!<CR>:lua require('lvim.core.log'):warn('File overwritten.')<CR>", "overwrite - force save" },
    y = { ":BufferCloseBuffersLeft<CR>", "close all buffers to the left" },
    Y = { ":BufferCloseBuffersRight<CR>", "close all buffers to the right" },
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
    r = { ":TelescopeRipgrepInteractive<CR>", "ripgrep interactive" },
    d = {
      ":TelescopeRipgrepDirty<CR>",
      "dirty fuzzy grep",
    },
    p = { ":Telescope find_files<CR>", "find file" },
    R = { ":Telescope registers<CR>", "list registers" },
    t = { ":TelescopeRipgrepString<CR>", "grep string" },
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
    c = { ":GDiffCompare<CR>", "compare with branch" },
    C = { ":Gdiffsplit<CR>", "diff split" },
    e = { ":Gedit<CR>", "edit version" },
    f = { ":Telescope git_files<CR>", "list git tracked files" },
    n = { ":lua require 'gitsigns'.next_hunk()<cr>", "next hunk" },
    p = { ":lua require 'gitsigns'.prev_hunk()<cr>", "prev hunk" },
    b = { ":lua require 'gitsigns'.blame_line()<cr>", "git hover blame" },
    k = { ":lua require 'gitsigns'.preview_hunk()<cr>", "preview hunk" },
    U = { ":lua require 'gitsigns'.reset_hunk()<cr>", "reset hunk" },
    R = { ":lua require 'gitsigns'.reset_buffer()<cr>", "reset buffer" },
    S = { ":lua require 'gitsigns'.stage_hunk()<cr>", "stage hunk" },
    s = { ":lua require 'gitsigns'.undo_stage_hunk()<cr>", "undo stage hunk" },
    m = { ":Gvdiffsplit!<CR>", "merge view, 3-way-split" },
    v = { ":Telescope git_bcommits<CR>", "list buffer commits" },
    V = { ":Telescope git_commits<CR>", "list workspace commits" },
    o = { ":Telescope git_status<cr>", "open git status" },
    d = {
      ":Gitsigns diffthis HEAD<cr>",
      "Git Diff",
    },
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
    a = { ":LspCodeAction<CR>", "code action" },
    w = { ":LspDocumentDiagonistics<CR>", "document diagnostics" },
    W = { ":LspWorkspaceDiagonistics<CR>", "workspace diagnostics" },
    f = { ":LspFormat<CR>", "format buffer" },
    F = { ":LvimToggleFormatOnSave<CR>", "toggle autoformat" },
    g = { ":LspOrganizeImports<CR>", "organize imports" },
    i = { ":LspInfo<cr>", "lsp information" },
    I = { ":LspInstallInfo<cr>", "lsp installer info" },
    m = { ":LspRenameFile<CR>", "rename with lsp" },
    h = { ":LspImportAll<CR>", "import all missing" },
    H = { ":LspImportCurrent<CR>", "import current" },
    n = {
      ":LspGotoNext<CR>",
      "next diagnostic",
    },
    p = {
      ":LspGotoPrev<CR>",
      "prev diagnostic",
    },
    l = { ":LspCodeLens<CR>", "codelens action" },
    R = { ":LspRename<CR>", "rename item under cursor" },
    q = { ":LspDiagonisticsSetList<CR>", "set quickfix list" },
    s = { ":LspDocumentSymbol<CR>", "document symbols" },
    S = { ":LspWorkspaceSymbol<CR>", "workspace symbols" },
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
      "<cmd>edit " .. get_config_dir() .. "/config.lua<cr>",
      "Edit config.lua",
    },
    f = {
      "<cmd>lua require('lvim.core.telescope.custom-finders').find_lunarvim_files()<cr>",
      "Find LunarVim files",
    },
    g = {
      "<cmd>lua require('lvim.core.telescope.custom-finders').grep_lunarvim_files()<cr>",
      "Grep LunarVim files",
    },
    k = { "<cmd>Telescope keymaps<cr>", "View LunarVim's keymappings" },
    i = {
      "<cmd>lua require('lvim.core.info').toggle_popup(vim.bo.filetype)<cr>",
      "Toggle LunarVim Info",
    },
    I = {
      "<cmd>lua require('lvim.core.telescope.custom-finders').view_lunarvim_changelog()<cr>",
      "View LunarVim's changelog",
    },
    l = {
      name = "+logs",
      d = {
        "<cmd>lua require('lvim.core.terminal').toggle_log_view(require('lvim.core.log').get_path())<cr>",
        "view default log",
      },
      D = {
        "<cmd>lua vim.fn.execute('edit ' .. require('lvim.core.log').get_path())<cr>",
        "Open the default logfile",
      },
      l = {
        "<cmd>lua require('lvim.core.terminal').toggle_log_view(vim.lsp.get_log_path())<cr>",
        "view lsp log",
      },
      L = { "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>", "Open the LSP logfile" },
      n = {
        "<cmd>lua require('lvim.core.terminal').toggle_log_view(os.getenv('NVIM_LOG_FILE'))<cr>",
        "view neovim log",
      },
      N = { "<cmd>edit $NVIM_LOG_FILE<cr>", "Open the Neovim logfile" },
      p = {
        "<cmd>lua require('lvim.core.terminal').toggle_log_view('packer.nvim')<cr>",
        "view packer log",
      },
      P = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<cr>", "Open the Packer logfile" },
    },
    r = { "<cmd>LvimReload<cr>", "Reload LunarVim's configuration" },
    u = { "<cmd>LvimUpdate<cr>", "Update LunarVim" },
  },

  P = {
    name = "Packer",
    c = { ":PackerCompile<cr>", "packer compile" },
    i = { ":PackerInstall<cr>", "packer install" },
    r = { ":lua require('lvim.plugin-loader').recompile()<cr>", "packer re-compile" },
    s = { ":PackerSync<cr>", "packer sync" },
    S = { ":PackerStatus<cr>", "packer status" },
    u = { ":PackerUpdate<cr>", "packer update" },
  },

  T = {
    name = "Treesitter",
    i = { ":TSConfigInfo<cr>", "treesitter info" },
    k = { ":TSHighlightCapturesUnderCursor<CR>", "show treesitter theme color" },
    u = { ":TSUpdate<CR>", "update installed treesitter packages" },
    U = { ":TSUninstall all<CR>", "uninstall all treesitter packages" },
    R = { ":TSInstall all<CR>", "reinstall all treesitter packages" },
  },
}

return M
