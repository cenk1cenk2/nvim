local M = {}

function M.q_close_autocmd(pattern)
  return {
    "FileType",
    {
      group = "_buffer_mappings",
      pattern = pattern,
      callback = function(event)
        vim.keymap.set("n", "q", function()
          vim.api.nvim_buf_delete(event.buf, { force = true })
        end, { silent = true, buffer = event.buf })
      end,
    },
  }
end

function M.setup()
  require("utils.setup").init({
    autocmds = {
      M.q_close_autocmd({
        "qf",
        "help",
        "man",
        "floaterm",
        "lspinfo",
        "lsp-installer",
        "dap-float",
        "lspsagaoutline",
        "neotest-summary",
      }),
      {
        { "BufWinEnter", "BufRead", "BufNewFile" },
        {
          group = "_format_options",
          pattern = "*",
          callback = function()
            vim.opt_local.formatoptions:remove("c")
            vim.opt_local.formatoptions:remove("r")
            vim.opt_local.formatoptions:remove("o")
          end,
        },
      },
      {
        "TextYankPost",
        {
          group = "_filetype_settings",
          pattern = "*",
          desc = "Highlight text on yank",
          callback = function()
            require("vim.highlight").on_yank({ higroup = "Search", timeout = 500 })
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
            vim.cmd([[wincmd J]])
          end,
        },
      },
      -- {
      --   "FileType",
      --   {
      --     group = "_filetype_settings",
      --     pattern = { "gitcommit", "markdown" },
      --     callback = function()
      --       vim.bo.spell = true
      --     end,
      --   },
      -- },
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
          callback = function(event)
            vim.opt_local.wrap = false
          end,
        },
      },
      -- {
      --   { "BufDelete", "LspDetach" },
      --   {
      --     group = "_lsp_cleanup",
      --     callback = function()
      --       -- somehow the lsp clients does not get automatically deallocated from the buffer
      --       vim.schedule(function()
      --         local clients = vim.lsp.get_clients()
      --
      --         for _, client in pairs(clients) do
      --           if client.attached_buffers == nil or #vim.tbl_keys(client.attached_buffers) == 0 then
      --             vim.lsp.stop_client(client.id)
      --           end
      --         end
      --       end)
      --     end,
      --   },
      -- },
      -- NOTE: Telescope opens file in insert mode after neovim commit: d52cc66
      -- Ref: https://github.com/nvim-telescope/telescope.nvim/issues/2501#issuecomment-1541009573
      -- Neovim commit pull request: https://github.com/neovim/neovim/pull/22984
      -- Workaround: Leave insert mode when leaving Telescope prompt.
      -- Ref: https://github.com/nvim-telescope/telescope.nvim/issues/2027#issuecomment-1510001730
      {
        "WinLeave",
        {
          group = "_telescope",
          pattern = "*",
          callback = function()
            if vim.bo.filetype == "TelescopePrompt" and vim.fn.mode() == "i" then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "i", true)
            end
          end,
        },
      },
    },
  })
end

return M
