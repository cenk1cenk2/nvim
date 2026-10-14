-- https://github.com/nvim-focus/focus.nvim
local M = {}

M.name = "nvim-focus/focus.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-focus/focus.nvim",
      }
    end,
    setup = function()
      return {
        commands = false,
        autoresize = {
          enable = false,
          minwidth = 5,
        },
        ui = {
          signcolumn = false,
          cursorline = false,
        },
      }
    end,
    configure = function()
      vim.opt.winminwidth = 0
      vim.opt.equalalways = false
    end,
    on_setup = function(c)
      require("focus").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "w" }),
          function()
            require("focus.modules.resizer").equalise()
          end,
          desc = "balance open windows",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "m" }),
          function()
            M.toggle_maximize()
          end,
          desc = "toggle maximize current window",
        },
      }
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<C-w>m",
          function()
            M.toggle_maximize()
          end,
          desc = "toggle maximize current window",
          mode = { "n" },
        },
      }
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = "VimResized",
          group = "_auto_resize",
          pattern = "*",
          callback = function()
            require("focus.modules.resizer").equalise()
          end,
        },
        {
          event = "WinEnter",
          group = "_focus_disable",
          clear = true,
          callback = function()
            local ignore_buftypes = { "quickfix", "nofile", "prompt", "popup" }
            vim.w.focus_disable = vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
          end,
        },
        {
          event = "FileType",
          group = "_focus_disable_ft",
          clear = true,
          callback = function()
            vim.b.focus_disable = vim.tbl_contains(nvim.disabled_filetypes, vim.bo.filetype)
          end,
        },
      }
    end,
  })
end

function M.toggle_maximize()
  local win = vim.api.nvim_get_current_win()
  local maximized = vim.t.maximized_window

  if maximized then
    vim.t.maximized_window = nil
    vim.cmd(maximized.layout)

    if maximized.win == win then
      return
    end
  end

  vim.t.maximized_window = { win = win, layout = vim.fn.winrestcmd() }
  require("focus.modules.resizer").maximise()
end

return M
