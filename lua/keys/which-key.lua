local M = {}

M.vmappings = {}

M.mappings = {
  ['='] = {'<C-W>=<CR>', 'balance windows'},
  ['E'] = {':Telescope file_browser<CR>', 'file-browser'},
  ['h'] = {'<C-W>s', 'split below'},
  ['v'] = {'<C-W>v', 'split right'},
  ['n'] = {'<cmd>nohlsearch<CR>', 'no highlight'},
  ['p'] = {':Telescope find_files theme=get_dropdown<CR>', 'find file'},
  ['r'] = {':RnvimrToggle<CR>', 'ranger'},
  ['q'] = {':LspFixCurrent<CR>', 'quick fix'},

  -- actions
  a = {
    name = '+actions',
    c = {':set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>', 'bring back cursor'},
    d = {':! ansible-vault decrypt %:p<CR>', 'ansible-vault decrypt'},
    D = {':! ansible-vault encrypt %:p<CR>', 'ansible-vault encrypt'},
    e = {':set ff=unix<CR>', 'set lf'},
    E = {':set ff=dos<CR>', 'set crlf'},
    f = {':Telescope filetypes<CR>', 'select from filetypes'},
    l = {':set nonumber!<CR>', 'line-numbers'},
    r = {':set norelativenumber!<CR>', 'relative line nums'},
    s = {':setlocal spell!<CR>', 'toggle spell check'},
    t = {':!markdown-toc %:p --bullets="-" -i<CR>', 'markdown-toc'},
    R = {':! cd ~/.config/nvim/utils && bash install-latest-neovim.sh && bash install-lsp.sh clean<CR>', 'rebuild neovim'}
  },

  -- buffer
  b = {
    name = '+buffer',
    b = {':BufferPick<CR>', 'pick buffer'},
    d = {':Bdelete<CR>', 'delete-buffer'},
    C = {':BufferWipeout<CR>', 'close-all'},
    e = {':e<CR>', 're-open current buffer'},
    f = {':Telescope buffers<CR>', 'find buffer'},
    E = {':e!<CR>', 're-open current buffer force'},
    x = {':BufferClose!<CR>', 'force-close buffer'},
    X = {':BufferCloseAllButCurrent<CR>', 'close-all but current'},
    p = {':BufferPin<CR>', 'pin buffer'},
    P = {':BufferCloseAllButPinned<CR>', 'close-all but pinned'},
    s = {':edit #', 'switch to last buffer'},
    y = {':BufferCloseBuffersLeft<CR>', 'close-all to left'},
    Y = {':BufferCloseBuffersRight<CR>', 'close-all to right'}
  },

  -- find
  f = {
    name = '+search',
    A = {':Telescope builtin<CR>', 'telescope list all command'},
    b = {':Telescope current_buffer_fuzzy_find<CR>', 'current buffer'},
    f = {':Telescope oldfiles<CR>', 'file history'},
    ['.'] = {':Telescope commands<CR>', 'commands'},
    [':'] = {':Telescope command_history<CR>', 'command history'},
    g = {':Telescope grep_string<CR>', 'grep string under cursor'},
    m = {':CocCommand fzf-preview.Bookmarks<CR>', 'list bookmarks'},
    j = {':Telescope jumplist<CR>', 'jumps'},
    k = {':Telescope keymaps<CR>', 'keymaps'},
    s = {':Telescope spell_suggest<CR>', 'spell suggest'},
    r = {':TelescopeRipgrepInteractive<CR>', 'rg interactive'},
    p = {':Telescope find_files theme=get_dropdown<CR>', 'find file'},
    R = {':Telescope registers<CR>', 'registers'},
    t = {':Telescope live_grep<CR>', 'text-telescope'},
    O = {':Telescope vim_options<CR>', 'vim options'}
  },

  -- find and replace
  s = {
    name = '+find & replace',
    f = {':FindAndReplace<CR>', 'find and replace'},
    s = {':FindAndReplaceVisual<CR>', 'find this visual'},
    b = {':FindAndReplaceInBuffer<CR>', 'search in current buffer'}
  },

  -- git
  g = {
    name = '+git',
    A = {':0Gclog<CR>', 'buffer commits'},
    B = {':Git blame<CR>', 'blame'},
    c = {':GDiffCompare<CR>', 'compare with branch'},
    C = {':Gdiffsplit<CR>', 'diff split'},
    e = {':Gedit<CR>', 'edit-version'},
    f = {':Telescope git_files<CR>', 'git_files'},
    n = {'<cmd>lua require \'gitsigns\'.next_hunk()<cr>', 'Next Hunk'},
    p = {'<cmd>lua require \'gitsigns\'.prev_hunk()<cr>', 'Prev Hunk'},
    b = {'<cmd>lua require \'gitsigns\'.blame_line()<cr>', 'Blame'},
    k = {'<cmd>lua require \'gitsigns\'.preview_hunk()<cr>', 'Preview Hunk'},
    U = {'<cmd>lua require \'gitsigns\'.reset_hunk()<cr>', 'Reset Hunk'},
    S = {'<cmd>lua require \'gitsigns\'.stage_hunk()<cr>', 'Stage Hunk'},
    s = {'<cmd>lua require \'gitsigns\'.undo_stage_hunk()<cr>', 'Undo Stage Hunk'},
    m = {':Gdiffsplit<CR>', 'merge view'},
    M = {':Gvdiffsplit!<CR>', 'merge view, 3-way-split'},
    t = {'<cmd>lua require \'gitsigns\'.toggle()<cr>', 'git signs toggle'},
    v = {':Telescope git_bcommits<CR>', 'view buffer commits'},
    V = {':Telescope git_commits<CR>', 'view commits'}
  },

  -- gist
  G = {
    name = '+gist',
    f = {':CocList gist<CR>', 'list'},
    p = {':CocCommand gist.create<CR>', 'post gist'},
    I = {':Telescope gh issues<CR>', 'github issues'},
    P = {':Telescope gh pull_request<CR>', 'github pull requests'},
    U = {':CocCommand gist.update<CR>', 'github gists'}
  },

  -- lsp
  l = {
    name = 'LSP',
    a = {'<cmd>lua require(\'core.telescope\').code_actions()<cr>', 'Code Action'},
    w = {'<cmd>Telescope lsp_document_diagnostics<cr>', 'Document Diagnostics'},
    W = {'<cmd>Telescope lsp_workspace_diagnostics<cr>', 'Workspace Diagnostics'},
    f = {'<cmd>lua vim.lsp.buf.formatting()<cr>', 'Format'},
    g = {':LspOrganizeImports<CR>', 'organize imports'},
    i = {'<cmd>LspInfo<cr>', 'Info'},
    I = {'<cmd>LspInstallInfo<cr>', 'Installer Info'},
    m = {':LspRenameFile<CR>', 'rename'},
    n = {'<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = lvim.lsp.popup_border}})<cr>', 'Next Diagnostic'},
    p = {'<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = lvim.lsp.popup_border}})<cr>', 'Prev Diagnostic'},
    l = {'<cmd>lua vim.lsp.codelens.run()<cr>', 'CodeLens Action'},
    P = {
      name = 'Peek',
      d = {'<cmd>lua require(\'lvim.lsp.peek\').Peek(\'definition\')<cr>', 'Definition'},
      t = {'<cmd>lua require(\'lvim.lsp.peek\').Peek(\'typeDefinition\')<cr>', 'Type Definition'},
      i = {'<cmd>lua require(\'lvim.lsp.peek\').Peek(\'implementation\')<cr>', 'Implementation'}
    },
    R = {':LspRename<CR>', 'rename item'},
    q = {'<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', 'Quickfix'},
    r = {'<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename'},
    s = {'<cmd>Telescope lsp_document_symbols<cr>', 'Document Symbols'},
    S = {'<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', 'Workspace Symbols'},
    Q = {':LspRestart<CR>', 'restart currently active lsps'}
  },

  -- node modules
  m = {
    name = 'node',
    s = {':lua require("package-info").show()<CR>', 'show package-info'},
    S = {':lua require("package-info").hide()<CR>', 'hide package-info'},
    u = {':lua require("package-info").update()<CR>', 'update current package'},
    d = {':lua require("package-info").delete()<CR>', 'delete current package'},
    i = {':lua require("package-info").install()<CR>', 'install packages'},
    r = {':lua require("package-info").reinstall()<CR>', 'reinstall packages'},
    c = {':lua require("package-info").change_version()<CR>', 'change version of the package'},
    m = {':Telescope node_modules list<CR>', 'node modules'}
  },

  -- workspace/session
  w = {
    name = '+Session',
    c = {':Dashboard<CR>', 'Dashboard'},
    q = {':qa<CR>', 'Quit while saved'},
    Q = {':qa!<CR>', 'Quit'},
    l = {':SessionLoad<CR>', 'Load Session'},
    s = {':SessionSave<CR>', 'Save Session'},
    f = {':CocList sessions<CR>', 'List Session'},
    p = {'<cmd>Telescope projects<CR>', 'Projects'}
  },

  L = {
    name = '+LunarVim',
    c = {'<cmd>edit' .. get_config_dir() .. '/config.lua<cr>', 'Edit config.lua'},
    f = {'<cmd>lua require(\'lvim.core.telescope.custom-finders\').find_lunarvim_files()<cr>', 'Find LunarVim files'},
    g = {'<cmd>lua require(\'lvim.core.telescope.custom-finders\').grep_lunarvim_files()<cr>', 'Grep LunarVim files'},
    k = {'<cmd>lua require(\'lvim.keymappings\').print()<cr>', 'View LunarVim\'s default keymappings'},
    i = {'<cmd>lua require(\'lvim.core.info\').toggle_popup(vim.bo.filetype)<cr>', 'Toggle LunarVim Info'},
    I = {'<cmd>lua require(\'lvim.core.telescope.custom-finders\').view_lunarvim_changelog()<cr>', 'View LunarVim\'s changelog'},
    l = {
      name = '+logs',
      d = {'<cmd>lua require(\'lvim.core.terminal\').toggle_log_view(require(\'lvim.core.log\').get_path())<cr>', 'view default log'},
      D = {'<cmd>lua vim.fn.execute(\'edit \' .. require(\'lvim.core.log\').get_path())<cr>', 'Open the default logfile'},
      l = {'<cmd>lua require(\'lvim.core.terminal\').toggle_log_view(vim.lsp.get_log_path())<cr>', 'view lsp log'},
      L = {'<cmd>lua vim.fn.execute(\'edit \' .. vim.lsp.get_log_path())<cr>', 'Open the LSP logfile'},
      n = {'<cmd>lua require(\'lvim.core.terminal\').toggle_log_view(os.getenv(\'NVIM_LOG_FILE\'))<cr>', 'view neovim log'},
      N = {'<cmd>edit $NVIM_LOG_FILE<cr>', 'Open the Neovim logfile'},
      p = {'<cmd>lua require(\'lvim.core.terminal\').toggle_log_view(\'packer.nvim\')<cr>', 'view packer log'},
      P = {'<cmd>exe \'edit \'.stdpath(\'cache\').\'/packer.nvim.log\'<cr>', 'Open the Packer logfile'}
    },
    r = {'<cmd>lua require(\'lvim.utils\').reload_lv_config()<cr>', 'Reload configurations'},
    u = {'<cmd>LvimUpdate<cr>', 'Update LunarVim'}
  },

  P = {
    name = 'Packer',
    c = {'<cmd>PackerCompile<cr>', 'Compile'},
    i = {'<cmd>PackerInstall<cr>', 'Install'},
    r = {'<cmd>lua require(\'lvim.utils\').reload_lv_config()<cr>', 'Reload'},
    s = {'<cmd>PackerSync<cr>', 'Sync'},
    S = {'<cmd>PackerStatus<cr>', 'Status'},
    u = {'<cmd>PackerUpdate<cr>', 'Update'}
  },
  T = {name = 'Treesitter', i = {':TSConfigInfo<cr>', 'Info'}, k = {':TSHighlightCapturesUnderCursor<CR>', 'show treesitter theme color'}}
}

return M