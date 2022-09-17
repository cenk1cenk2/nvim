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
    name = "actions",
    c = { ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>", "bring back cursor" },
    e = { ":set ff=unix<CR>", "set lf" },
    E = { ":set ff=dos<CR>", "set crlf" },
    f = { ":Telescope filetypes<CR>", "select from filetypes" },
    l = { ":set nonumber!<CR>", "toggle line numbers" },
    r = { ":set norelativenumber!<CR>", "toggle relative line numbers" },
    s = { ":setlocal spell!<CR>", "toggle spell check" },
  },

  -- buffer
  b = {
    name = "buffer",
    e = { ":e<CR>", "reopen current buffer" },
    E = { ":e!<CR>", "force reopen current buffer" },
    f = { ":Telescope buffers<CR>", "find buffer" },
    s = { ":edit #<CR>", "switch to last buffer" },
    S = {
      function()
        vim.cmd "w!"
        require("lvim.core.log"):warn "File overwritten."
      end,
      "overwrite - force save",
    },
  },

  -- find
  f = {
    name = "find",
    ["."] = { ":Telescope commands<CR>", "search available commands" },
    [":"] = { ":Telescope command_history<CR>", "search command history" },
    A = { ":Telescope builtin<CR>", "telescope list builtin finders" },
    b = { ":Telescope current_buffer_fuzzy_find<CR>", "search current buffer fuzzy" },
    B = {
      function()
        require("modules.telescope").rg_grep_buffer()
      end,
      "search current buffer grep",
    },
    f = { ":Telescope oldfiles<CR>", "search file history" },
    g = { ":Telescope grep_string<CR>", "grep string under cursor" },
    m = { ":Telescope vim_bookmarks all<CR>", "list all bookmarks" },
    M = { ":Telescope vim_bookmarks current_file<CR>", "list document bookmarks" },
    j = { ":Telescope jumplist<CR>", "list jumps" },
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
    t = {
      function()
        require("modules.telescope").rg_string()
      end,
      "grep string",
    },
    T = { ":Telescope live_grep<CR>", "grep with regexp" },
  },

  -- git
  g = {
    name = "git",
    f = { ":Telescope git_status<CR>", "git status" },
    F = { ":Telescope git_files<CR>", "list git tracked files" },
  },

  -- gist
  G = {
    name = "gist",
    I = { ":Telescope gh issues<CR>", "github issues" },
    P = { ":Telescope gh pull_request<CR>", "github pull requests" },
  },

  -- lsp
  l = {
    name = "lsp",
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
      function()
        require("lvim.core.info").toggle_popup(vim.bo.filetype)
      end,
      "lsp info",
    },
    I = { ":Mason<CR>", "lsp installer" },
    m = { ":LspRenameFile<CR>", "rename file with lsp" },
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
  },

  -- workspace/session
  w = {
    name = "+session",
    q = {
      function()
        require("lvim.utils.functions").smart_quit()
      end,
      "quit",
    },
  },

  L = {
    name = "+neovim",
    k = { ":Telescope keymaps<CR>", "list keymaps" },
    l = {
      name = "+logs",
      d = {
        function()
          lvim.fn.toggle_log_view(require("lvim.core.log").get_path())
        end,
        "view default log",
      },
      D = {
        function()
          vim.fn.execute("edit " .. require("lvim.core.log").get_path())
        end,
        "open the default logfile",
      },
      l = {
        function()
          lvim.fn.toggle_log_view(vim.lsp.get_log_path())
        end,
        "view lsp log",
      },
      L = {
        function()
          vim.fn.execute("edit " .. vim.lsp.get_log_path())
        end,
        "open the lsp logfile",
      },
      n = {
        function()
          lvim.fn.toggle_log_view(os.getenv "NVIM_LOG_FILE")
        end,
        "view neovim log",
      },
      N = { ":edit $NVIM_LOG_FILE<CR>", "open the neovim logfile" },
      p = {
        function()
          lvim.fn.toggle_log_view "packer.nvim"
        end,
        "view packer log",
      },
      P = { ":exe 'edit '.stdpath('cache').'/packer.nvim.log'<CR>", "open the packer logfile" },
    },
    r = { ":LvimReload<CR>", "reload configuration" },
    u = { ":LvimUpdate<CR>", "git update config repository" },
  },

  P = {
    name = "packer",
    c = { ":PackerCompile<CR>", "packer compile" },
    i = { ":PackerInstall<CR>", "packer install" },
    r = {
      function()
        require("lvim.plugin-loader").recompile()
      end,
      "recompile",
    },
    s = { ":PackerSync<CR>", "packer sync" },
    S = { ":PackerStatus<CR>", "packer status" },
    u = { ":PackerUpdate<CR>", "packer update" },
  },

  R = {
    name = "tasks",
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
