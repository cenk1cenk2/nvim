local M = {}

M.CATEGORIES = {
  ACTIONS = "a",
  BUFFER = "b",
  COPILOT = "c",
  DEBUG = "d",
  DEPENDENCIES = "D",
  FIND = "f",
  SEARCH = "s",
  GIT = "g",
  LSP = "l",
  BOOKMARKS = "m",
  NOTES = "n",
  TESTS = "j",
  TERMINAL = "t",
  SESSION = "w",
  NEOVIM = "L",
  PLUGINS = "P",
  TASKS = "r",
  BUILD = "R",
  TREESITTER = "T",
}

local fn = require("utils.setup").fn

M.wk = {
  {
    fn.wk_keystroke({ "x" }),
    "<C-W>s",
    desc = "split below",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ "v" }),
    "<C-W>v",
    desc = "split right",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ "N" }),
    ":nohlsearch<CR>",
    desc = "no highlight",
    mode = { "n", "v" },
  },

  -- actions

  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS }),
    group = "actions",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "a" }),
    "ggVG",
    desc = "select all",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "c" }),
    ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>",
    desc = "bring back cursor",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "e" }),
    ":set ff=unix<CR>",
    desc = "set lf",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "E" }),
    ":set ff=dos<CR>",
    desc = "set crlf",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "l" }),
    ":set nonumber!<CR>",
    desc = "toggle line numbers",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "L" }),
    ":set norelativenumber!<CR>",
    desc = "toggle relative line numbers",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "w" }),
    "<C-W>=<CR>",
    desc = "balance open windows",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "R" }),
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    desc = "redraw",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "b" }),
    ":wincmd p | q<CR>",
    desc = "previous window",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "s" }),
    ":sort<CR>",
    desc = "sort",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "S" }),
    ":set signcolumn=yes<CR>",
    desc = "fix sign columns",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "t" }),
    ":setlocal wrap!<CR>",
    desc = "toggle wrap",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "T" }),
    ":setlocal bufhidden=delete<CR>",
    desc = "set as temporary buffer",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "q" }),
    ":colder<CR>",
    desc = "quickfix older",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.ACTIONS, "Q" }),
    ":cnewer<CR>",
    desc = "quickfix newer",
  },

  -- buffer

  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER }),
    group = "buffer",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "e" }),
    ":e<CR>",
    desc = "reopen current buffer",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "E" }),
    ":e!<CR>",
    desc = "force reopen current buffer",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "s" }),
    ":edit #<CR>",
    desc = "switch to last buffer",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "S" }),
    function()
      vim.cmd("w!")
      require("lvim.core.log"):warn("File overwritten.")
    end,
    desc = "overwrite - force save",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "w" }),
    function()
      vim.cmd("w")
    end,
    desc = "write",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.BUFFER, "W" }),
    function()
      vim.cmd("wa")
      require("lvim.core.log"):warn("Wrote all files.")
    end,
    desc = "write all",
    mode = { "n", "v" },
  },

  -- copilot

  {
    fn.wk_keystroke({ M.CATEGORIES.COPILOT }),
    group = "copilot",
    mode = { "n", "v" },
  },

  -- debug

  {
    fn.wk_keystroke({ M.CATEGORIES.DEBUG }),
    group = "debug",
    mode = { "n", "v" },
  },

  -- dependencies

  {
    fn.wk_keystroke({ M.CATEGORIES.DEPENDENCIES }),
    group = "dependencies",
    mode = { "n", "v" },
  },

  -- find

  {
    fn.wk_keystroke({ M.CATEGORIES.FIND }),
    group = "find",
    mode = { "n", "v" },
  },

  -- search

  {
    fn.wk_keystroke({ M.CATEGORIES.SEARCH }),
    group = "search",
    mode = { "n", "v" },
  },

  -- notes

  {
    fn.wk_keystroke({ M.CATEGORIES.NOTES }),
    group = "notes",
    mode = { "n", "v" },
  },

  -- git

  {
    fn.wk_keystroke({ M.CATEGORIES.GIT }),
    group = "git",
    mode = { "n", "v" },
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.GIT, "g" }),
    group = "github",
    mode = { "n", "v" },
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.DEBUG, "G" }),
    group = "gitlab",
    mode = { "n", "v" },
  },

  -- lsp

  {
    fn.wk_keystroke({ M.CATEGORIES.LSP }),
    group = "lsp",
    mode = { "n", "v" },
  },

  -- bookmarks

  {
    fn.wk_keystroke({ M.CATEGORIES.BOOKMARKS }),
    group = "bookmarks",
    mode = { "n", "v" },
  },

  -- terminal

  {
    fn.wk_keystroke({ M.CATEGORIES.TERMINAL }),
    group = "terminal",
    mode = { "n", "v" },
  },

  -- sessions

  {
    fn.wk_keystroke({ M.CATEGORIES.SESSION }),
    group = "session",
    mode = { "n", "v" },
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.SESSION, "r" }),
    function()
      vim.api.nvim_set_current_dir(vim.fn.fnamemodify(vim.fn.finddir(".git", ".;"), ":h"))
    end,
    desc = "cwd as git root",
    mode = { "n", "v" },
  },

  -- neovim

  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM }),
    group = "neovim",
    mode = { "n", "v" },
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l" }),
    group = "logs",
    mode = { "n", "v" },
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "d" }),
    function()
      lvim.fn.toggle_log_view(require("lvim.core.log").get_path())
    end,
    desc = "view default log",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "D" }),
    function()
      vim.fn.execute("edit " .. require("lvim.core.log").get_path())
    end,
    desc = "open the default logfile",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "l" }),
    function()
      lvim.fn.toggle_log_view(vim.lsp.get_log_path())
    end,
    desc = "view lsp log",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "L" }),
    function()
      vim.fn.execute("edit " .. vim.lsp.get_log_path())
    end,
    desc = "open the lsp logfile",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "n" }),
    function()
      lvim.fn.toggle_log_view(os.getenv("NVIM_LOG_FILE"))
    end,
    desc = "view neovim log",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "N" }),
    ":edit $NVIM_LOG_FILE<CR>",
    desc = "open the neovim logfile",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "l", "p" }),
    function()
      lvim.fn.toggle_log_view("lazy.nvim")
    end,
    desc = "view plugin manager log",
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "r" }),
    function()
      vim.cmd([[LvimReload]])
    end,
    desc = "reload configuration",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.NEOVIM, "p" }),
    function()
      vim.cmd([[LvimUpdate]])
    end,
    desc = "git update config repository",
  },

  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS }),
    group = "plugins",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "i" }),
    ":Lazy install<CR>",
    desc = "install",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "x" }),
    ":Lazy clean<CR>",
    desc = "clean",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "l" }),
    ":Lazy log<CR>",
    desc = "log",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "s" }),
    ":Lazy sync<CR>",
    desc = "sync",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "S" }),
    ":Lazy<CR>",
    desc = "status",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "r" }),
    ":Lazy restore<CR>",
    desc = "restore",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "p" }),
    ":Lazy profile<CR>",
    desc = "profile",
  },
  {
    fn.wk_keystroke({ M.CATEGORIES.PLUGINS, "u" }),
    ":Lazy update<CR>",
    desc = "update",
  },

  -- tests

  {
    fn.wk_keystroke({ M.CATEGORIES.TESTS }),
    group = "tests",
  },

  -- tasks

  {
    fn.wk_keystroke({ M.CATEGORIES.TASKS }),
    group = "tasks",
  },

  -- build

  {
    fn.wk_keystroke({ M.CATEGORIES.BUILD }),
    group = "build",
  },

  -- treesitter

  {
    fn.wk_keystroke({ M.CATEGORIES.TREESITTER }),
    group = "treesitter",
  },
}

return M
