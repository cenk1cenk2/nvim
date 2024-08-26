local M = {}

---@class WKCategories
---@field ACTIONS string
---@field BUFFER string
---@field COPILOT string
---@field DEBUG string
---@field FIND string
---@field SEARCH string
---@field GIT string
---@field LSP string
---@field LOGS string Subcategory.
---@field BOOKMARKS string
---@field NOTES string
---@field TESTS string
---@field TERMINAL string
---@field SESSION string
---@field NEOVIM string
---@field PLUGINS string
---@field TASKS string
---@field TREESITTER string

---@type WKCategories
M.CATEGORIES = {
  ACTIONS = "a",
  BUFFER = "b",
  COPILOT = "c",
  DEBUG = "d",
  FIND = "f",
  SEARCH = "s",
  GIT = "g",
  LSP = "l",
  LOGS = "?",
  BOOKMARKS = "m",
  NOTES = "n",
  TESTS = "j",
  TERMINAL = "t",
  SESSION = "w",
  NEOVIM = "N",
  PLUGINS = "P",
  TASKS = "r",
  TREESITTER = "T",
}

function M.setup()
  require("ck.setup").init({
    wk = function(_, categories, fn)
      return {
        {
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
            fn.wk_keystroke({ "'" }),
            ":nohlsearch<CR>",
            desc = "no highlight",
            mode = { "n", "v" },
          },

          -- localleader

          {
            fn.wk_keystroke({ nvim.localleader }),
            group = "local",
          },

          -- actions

          {
            fn.wk_keystroke({ categories.ACTIONS }),
            group = "actions",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "a" }),
            "ggVG",
            desc = "select all",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "c" }),
            ":set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20<CR>",
            desc = "bring back cursor",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "e" }),
            ":set ff=unix<CR>",
            desc = "set lf",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "E" }),
            ":set ff=dos<CR>",
            desc = "set crlf",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "l" }),
            ":set nonumber!<CR>",
            desc = "toggle line numbers",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "L" }),
            ":set norelativenumber!<CR>",
            desc = "toggle relative line numbers",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "w" }),
            "<C-W>=<CR>",
            desc = "balance open windows",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "R" }),
            "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
            desc = "redraw",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "b" }),
            ":wincmd p | q<CR>",
            desc = "previous window",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "s" }),
            ":sort<CR>",
            desc = "sort",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "S" }),
            ":set signcolumn=yes<CR>",
            desc = "fix sign columns",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "t" }),
            ":setlocal wrap!<CR>",
            desc = "toggle wrap",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "T" }),
            ":setlocal bufhidden=delete<CR>",
            desc = "set as temporary buffer",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "q" }),
            ":colder<CR>",
            desc = "quickfix older",
          },
          {
            fn.wk_keystroke({ categories.ACTIONS, "Q" }),
            ":cnewer<CR>",
            desc = "quickfix newer",
          },

          -- buffer

          {
            fn.wk_keystroke({ categories.BUFFER }),
            group = "buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "e" }),
            ":e<CR>",
            desc = "reopen current buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "E" }),
            ":e!<CR>",
            desc = "force reopen current buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "s" }),
            ":edit #<CR>",
            desc = "switch to last buffer",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "S" }),
            function()
              vim.cmd("w!")
              require("ck.log"):warn("File overwritten.")
            end,
            desc = "overwrite - force save",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "w" }),
            function()
              vim.cmd("w")
            end,
            desc = "write",
            mode = { "n", "v" },
          },
          {
            fn.wk_keystroke({ categories.BUFFER, "W" }),
            function()
              vim.cmd("wa")
              require("ck.log"):warn("Wrote all files.")
            end,
            desc = "write all",
            mode = { "n", "v" },
          },

          -- copilot

          {
            fn.wk_keystroke({ categories.COPILOT }),
            group = "copilot",
            mode = { "n", "v" },
          },

          -- debug

          {
            fn.wk_keystroke({ categories.DEBUG }),
            group = "debug",
            mode = { "n", "v" },
          },

          -- dependencies

          {
            fn.wk_keystroke({ categories.DEPENDENCIES }),
            group = "dependencies",
            mode = { "n", "v" },
          },

          -- find

          {
            fn.wk_keystroke({ categories.FIND }),
            group = "find",
            mode = { "n", "v" },
          },

          -- search

          {
            fn.wk_keystroke({ categories.SEARCH }),
            group = "search",
            mode = { "n", "v" },
          },

          -- notes

          {
            fn.wk_keystroke({ categories.NOTES }),
            group = "notes",
            mode = { "n", "v" },
          },

          -- git

          {
            fn.wk_keystroke({ categories.GIT }),
            group = "git",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.GIT, "g" }),
            group = "github",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.DEBUG, "G" }),
            group = "gitlab",
            mode = { "n", "v" },
          },

          -- lsp

          {
            fn.wk_keystroke({ categories.LSP }),
            group = "lsp",
            mode = { "n", "v" },
          },

          -- bookmarks

          {
            fn.wk_keystroke({ categories.BOOKMARKS }),
            group = "bookmarks",
            mode = { "n", "v" },
          },

          -- terminal

          {
            fn.wk_keystroke({ categories.TERMINAL }),
            group = "terminal",
            mode = { "n", "v" },
          },

          -- sessions

          {
            fn.wk_keystroke({ categories.SESSION }),
            group = "session",
            mode = { "n", "v" },
          },

          {
            fn.wk_keystroke({ categories.SESSION, "r" }),
            function()
              vim.api.nvim_set_current_dir(vim.fs.root(0, { ".git" }))
            end,
            desc = "cwd as git root",
            mode = { "n", "v" },
          },

          -- neovim

          {
            fn.wk_keystroke({ categories.PLUGINS }),
            group = "plugins",
          },

          -- tests

          {
            fn.wk_keystroke({ categories.TESTS }),
            group = "tests",
          },

          -- tasks

          {
            fn.wk_keystroke({ categories.TASKS }),
            group = "tasks",
          },

          -- neovim

          {
            fn.wk_keystroke({ categories.NEOVIM }),
            group = "neovim",
          },

          -- treesitter

          {
            fn.wk_keystroke({ categories.TREESITTER }),
            group = "treesitter",
          },
        },
      }
    end,
  })
end

return M
