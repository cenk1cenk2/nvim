local M = {}

M.CATEGORIES = {
  ACTIONS = "a",
  BUFFER = "b",
  DEBUG = "d",
  DEPENDENCIES = "D",
  FIND = "f",
  SEARCH = "s",
  GIT = "g",
  GIST = "G",
  LSP = "l",
  BOOKMARKS = "m",
  TESTS = "j",
  TERMINAL = "t",
  SESSION = "w",
  NEOVIM = "L",
  PACKER = "P",
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
    ["="] = { "<C-W>=<CR>", "balance open windows" },
    c = { ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>", "bring back cursor" },
    e = { ":set ff=unix<CR>", "set lf" },
    E = { ":set ff=dos<CR>", "set crlf" },
    l = { ":set nonumber!<CR>", "toggle line numbers" },
    r = { ":set norelativenumber!<CR>", "toggle relative line numbers" },
    s = { ":setlocal spell!<CR>", "toggle spell check" },
    S = { ":set signcolumns=yes:1<CR>", "fix sign columns" },
    T = { ":setlocal bufhidden=delete<CR>", "set as temporary buffer" },
  },

  -- buffer
  [M.CATEGORIES.BUFFER] = {
    name = "buffer",
    e = { ":e<CR>", "reopen current buffer" },
    E = { ":e!<CR>", "force reopen current buffer" },
    s = { ":edit #<CR>", "switch to last buffer" },
    S = {
      function()
        vim.cmd "w!"
        require("lvim.core.log"):warn "File overwritten."
      end,
      "overwrite - force save",
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
  },

  -- gist
  [M.CATEGORIES.GIST] = {
    name = "gist",
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
    q = {
      function()
        require("lvim.utils.functions").smart_quit()
      end,
      "quit",
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

  [M.CATEGORIES.PACKER] = {
    name = "packer",
    c = { ":PackerCompile<CR>", "packer compile" },
    i = { ":PackerInstall<CR>", "packer install" },
    r = {
      function()
        require("lvim.plugins").recompile()
      end,
      "recompile",
    },
    s = { ":PackerSync<CR>", "packer sync" },
    S = { ":PackerStatus<CR>", "packer status" },
    u = { ":PackerUpdate<CR>", "packer update" },
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

M.vmappings = {
  [M.CATEGORIES.ACTIONS] = M.mappings[M.CATEGORIES.ACTIONS],
  ["x"] = M.mappings["x"],
  ["v"] = M.mappings["v"],
  ["n"] = M.mappings["n"],
  ["p"] = M.mappings["p"],
}

return M
