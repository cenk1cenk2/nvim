local M = {}

M.config = function()
  lvim.builtin.which_key = {
    ---@usage disable which-key completely [not recommeded]
    active = true,
    on_config_done = nil,
    setup = {
      plugins = {
        marks = false, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        presets = {
          operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true -- bindings for prefixed with g,
        }
      },
      icons = {
        breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
        separator = '➜', -- symbol used between a key and it's label
        group = '+' -- symbol prepended to a group
      },
      window = {
        border = 'single', -- none, single, double, shadow
        position = 'bottom', -- bottom, top
        margin = {0, 0, 1, 0}, -- extra window margin [top, right, bottom, left]
        padding = {1, 1, 1, 1} -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = {min = 4, max = 25}, -- min and max height of the columns
        width = {min = 20, max = 50}, -- min and max width of the columns
        spacing = 3 -- spacing between columns
      },
      triggers = {'<leader>', 'g', 'z', '"', '<C-r>'}
    },

    opts = {
      mode = 'n', -- NORMAL mode
      prefix = '<leader>',
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true -- use `nowait` when creating keymaps
    },
    vopts = {
      mode = 'v', -- VISUAL mode
      prefix = '<leader>',
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true -- use `nowait` when creating keymaps
    },
    -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
    -- see https://neovim.io/doc/user/map.html#:map-cmd
    vmappings = {['/'] = {':CommentToggle<CR>', 'Comment'}},
    mappings = {
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
        a = {':DiffViewFileHistory<CR>', 'buffer commits'},
        A = {':0Gclog<CR>', 'buffer commits'},
        b = {':Git blame<CR>', 'blame'},
        c = {':GDiffCompare<CR>', 'compare with branch'},
        C = {':Gdiffsplit<CR>', 'diff split'},
        d = {':DiffViewOpen<CR>', 'diff-view open'},
        D = {':DiffViewClose<CR>', 'diff-view open'},
        e = {':Gedit<CR>', 'edit-version'},
        f = {':Telescope git_files<CR>', 'git_files'},
        k = {':GitSignsPreviewHunk<CR>', 'preview hunk'},
        n = {':GitSignsNextHunk<CR>', 'next hunk'},
        p = {':GitSignsPrevHunk<CR>', 'prev hunk'},
        m = {':Gdiffsplit<CR>', 'merge view'},
        M = {':Gvdiffsplit!<CR>', 'merge view, 3-way-split'},
        t = {':GitSignsToggle<CR>', 'toggle hunks'},
        U = {':GitSignsResetHunk<CR>', 'undo hunk'},
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
          d = {'<cmd>lua require(\'lsp.peek\').Peek(\'definition\')<cr>', 'Definition'},
          t = {'<cmd>lua require(\'lsp.peek\').Peek(\'typeDefinition\')<cr>', 'Type Definition'},
          i = {'<cmd>lua require(\'lsp.peek\').Peek(\'implementation\')<cr>', 'Implementation'}
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

      -- terminal
      t = {name = '+terminal'},

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
        f = {'<cmd>lua require(\'core.telescope\').find_lunarvim_files()<cr>', 'Find LunarVim files'},
        g = {'<cmd>lua require(\'core.telescope\').grep_lunarvim_files()<cr>', 'Grep LunarVim files'},
        k = {'<cmd>lua require(\'keymappings\').print()<cr>', 'View LunarVim\'s default keymappings'},
        i = {'<cmd>lua require(\'core.info\').toggle_popup(vim.bo.filetype)<cr>', 'Toggle LunarVim Info'},
        I = {'<cmd>lua require(\'core.telescope\').view_lunarvim_changelog()<cr>', 'View LunarVim\'s changelog'},
        l = {
          name = '+logs',
          d = {'<cmd>lua require(\'core.terminal\').toggle_log_view(require(\'core.log\').get_path())<cr>', 'view default log'},
          D = {'<cmd>lua vim.fn.execute(\'edit \' .. require(\'core.log\').get_path())<cr>', 'Open the default logfile'},
          l = {'<cmd>lua require(\'core.terminal\').toggle_log_view(vim.lsp.get_log_path())<cr>', 'view lsp log'},
          L = {'<cmd>lua vim.fn.execute(\'edit \' .. vim.lsp.get_log_path())<cr>', 'Open the LSP logfile'},
          n = {'<cmd>lua require(\'core.terminal\').toggle_log_view(os.getenv(\'NVIM_LOG_FILE\'))<cr>', 'view neovim log'},
          N = {'<cmd>edit $NVIM_LOG_FILE<cr>', 'Open the Neovim logfile'},
          p = {'<cmd>lua require(\'core.terminal\').toggle_log_view(\'packer.nvim\')<cr>', 'view packer log'},
          P = {'<cmd>exe \'edit \'.stdpath(\'cache\').\'/packer.nvim.log\'<cr>', 'Open the Packer logfile'}
        },
        r = {'<cmd>lua require(\'utils\').reload_lv_config()<cr>', 'Reload configurations'},
        u = {'<cmd>LvimUpdate<cr>', 'Update LunarVim'}
      },

      P = {
        name = 'Packer',
        c = {'<cmd>PackerCompile<cr>', 'Compile'},
        i = {'<cmd>PackerInstall<cr>', 'Install'},
        r = {'<cmd>lua require(\'utils\').reload_lv_config()<cr>', 'Reload'},
        s = {'<cmd>PackerSync<cr>', 'Sync'},
        S = {'<cmd>PackerStatus<cr>', 'Status'},
        u = {'<cmd>PackerUpdate<cr>', 'Update'}
      },

      T = {name = 'Treesitter', i = {':TSConfigInfo<cr>', 'Info'}, k = {':TSHighlightCapturesUnderCursor<CR>', 'show treesitter theme color'}}
    }
  }
end

M.setup = function()
  local which_key = require 'which-key'

  which_key.setup(lvim.builtin.which_key.setup)

  local opts = lvim.builtin.which_key.opts
  local vopts = lvim.builtin.which_key.vopts

  local mappings = lvim.builtin.which_key.mappings
  local vmappings = lvim.builtin.which_key.vmappings

  which_key.register(mappings, opts)
  which_key.register(vmappings, vopts)

  if lvim.builtin.which_key.on_config_done then lvim.builtin.which_key.on_config_done(which_key) end
end

return M
