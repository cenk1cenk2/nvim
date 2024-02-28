local M = {}

M.CATEGORIES = {
  ACTIONS = "a",
  BUFFER = "b",
  DEBUG = "d",
  DEPENDENCIES = "D",
  FIND = "f",
  SEARCH = "s",
  GIT = "g",
  LSP = "l",
  BOOKMARKS = "m",
  TESTS = "j",
  TERMINAL = "t",
  SESSION = "w",
  NEOVIM = "L",
  PLUGINS = "P",
  TASKS = "r",
  BUILD = "R",
  TREESITTER = "T",
}

M.mappings = {
  ["x"] = { "<C-W>s", "split below" },
  ["v"] = { "<C-W>v", "split right" },
  ["n"] = { ":nohlsearch<CR>", "no highlight" },

  -- actions
  [M.CATEGORIES.ACTIONS] = {
    name = "actions",
    a = { "ggVG", "select all" },
    c = { ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>", "bring back cursor" },
    e = { ":set ff=unix<CR>", "set lf" },
    E = { ":set ff=dos<CR>", "set crlf" },
    l = { ":set nonumber!<CR>", "toggle line numbers" },
    m = { "<C-W>=<CR>", "balance open windows" },
    r = { ":set norelativenumber!<CR>", "toggle relative line numbers" },
    R = { "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", "redraw" },
    b = { ":wincmd p | q<CR>", "previous window" },
    s = { ":sort<CR>", "sort" },
    S = { ":set signcolumn=yes<CR>", "fix sign columns" },
    t = { ":setlocal wrap!<CR>", "toggle wrap" },
    T = { ":setlocal bufhidden=delete<CR>", "set as temporary buffer" },
    q = { ":colder<CR>", "quickfix older" },
    Q = { ":cnewer<CR>", "quickfix newer" },
  },

  -- buffer
  [M.CATEGORIES.BUFFER] = {
    name = "buffer",
    e = { ":e<CR>", "reopen current buffer" },
    E = { ":e!<CR>", "force reopen current buffer" },
    s = { ":edit #<CR>", "switch to last buffer" },
    S = {
      function()
        vim.cmd("w!")
        require("lvim.core.log"):warn("File overwritten.")
      end,
      "overwrite - force save",
    },
    w = {
      function()
        vim.cmd("w")
      end,
      "write",
    },
    W = {
      function()
        vim.cmd("wa")
        require("lvim.core.log"):warn("Wrote all files.")
      end,
      "write all",
    },
  },

  [M.CATEGORIES.DEBUG] = {
    name = "debug",
  },

  [M.CATEGORIES.DEPENDENCIES] = {
    name = "dependencies",
  },

  -- find
  [M.CATEGORIES.FIND] = {
    name = "find",
  },

  [M.CATEGORIES.SEARCH] = {
    name = "search",
  },

  -- git
  [M.CATEGORIES.GIT] = {
    name = "git",
    ["g"] = {
      name = "github",
    },
    ["G"] = {
      name = "gitlab",
    },
  },

  -- lsp
  [M.CATEGORIES.LSP] = {
    name = "lsp",
  },

  [M.CATEGORIES.BOOKMARKS] = {
    name = "bookmarks",
  },

  -- terminal
  [M.CATEGORIES.TERMINAL] = {
    name = "terminal",
  },

  -- workspace/session
  [M.CATEGORIES.SESSION] = {
    name = "session",
    r = {
      function()
        vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h"))
      end,
      "cwd as git root",
    },
  },

  [M.CATEGORIES.NEOVIM] = {
    name = "neovim",
    l = {
      name = "logs",
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
          lvim.fn.toggle_log_view(os.getenv("NVIM_LOG_FILE"))
        end,
        "view neovim log",
      },
      N = { ":edit $NVIM_LOG_FILE<CR>", "open the neovim logfile" },
      p = {
        function()
          lvim.fn.toggle_log_view("lazy.nvim")
        end,
        "view plugin manager log",
      },
    },
    r = { ":LvimReload<CR>", "reload configuration" },
    p = { ":LvimUpdate<CR>", "git update config repository" },
  },

  [M.CATEGORIES.PLUGINS] = {
    name = "plugins",
    i = { ":Lazy install<CR>", "install" },
    x = { ":Lazy clean<CR>", "clean" },
    l = { ":Lazy log<CR>", "log" },
    s = { ":Lazy sync<CR>", "sync" },
    S = { ":Lazy<CR>", "status" },
    r = { ":Lazy restore<CR>", "restore" },
    p = { ":Lazy profile<CR>", "profile" },
    u = { ":Lazy update<CR>", "update" },
  },

  [M.CATEGORIES.TESTS] = {
    name = "tests",
  },

  [M.CATEGORIES.TASKS] = {
    name = "tasks",
  },

  [M.CATEGORIES.BUILD] = {
    name = "build",
  },

  [M.CATEGORIES.TREESITTER] = {
    name = "treesitter",
  },
}

M.vmappings = vim.deepcopy(M.mappings)

return M
