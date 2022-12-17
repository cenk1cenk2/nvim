local M = {}

function M.setup()
  require("utils.setup").run {
    autocmds = {
      {
        "FileType",
        {
          group = "_buffer_mappings",
          pattern = {
            "qf",
            "help",
            "man",
            "floaterm",
            "lspinfo",
            "lsp-installer",
            "null-ls-info",
            "dap-float",
            "lspsagaoutline",
          },
          command = "nnoremap <silent> <buffer> q :close<CR>",
        },
      },
      {
        { "BufWinEnter", "BufRead", "BufNewFile" },
        {
          group = "_format_options",
          pattern = "*",
          command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
        },
      },
      {
        "TextYankPost",
        {
          group = "_filetype_settings",
          pattern = "*",
          desc = "Highlight text on yank",
          callback = function()
            require("vim.highlight").on_yank { higroup = "Search", timeout = 500 }
          end,
        },
      },
      {
        "FileType",
        {
          group = "_filetype_settings",
          pattern = "qf",
          callback = function()
            vim.bo.buflisted = false
          end,
        },
      },
      {
        "FileType",
        {
          group = "_filetype_settings",
          pattern = { "gitcommit", "markdown" },
          callback = function()
            vim.bo.spell = true
          end,
        },
      },
      {
        "FileType",
        {
          group = "_filetype_settings",
          pattern = {
            "gitcommit",
            "gitrebase",
            "gitconfig",
          },
          callback = function()
            vim.bo.bufhidden = "delete"
          end,
        },
      },
      {
        "FileType",
        {
          group = "_filetype_settings",
          pattern = "gitcommit",
          callback = function()
            vim.bo.wrap = true
          end,
        },
      },
      {
        "FileType",
        {
          group = "_filetype_settings",
          pattern = "yaml.ansible",
          callback = function()
            require("lvim.lsp.manager").setup "ansiblels"
          end,
        },
      },
    },
  }
end

return M
