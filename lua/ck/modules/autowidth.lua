local M = {}

--- Share of the total columns the focused window is grown to.
local WIDTH_RATIO = 0.25

---@type string?
local restore = nil

--- 'winwidth' is global and Neovim applies it to the window being entered only
--- after `WinEnter` has run, so lowering it there is what keeps an ignored
--- window at the width it picked for itself.
local function set_winwidth()
  local ignored = vim.tbl_contains(nvim.disabled_filetypes, vim.bo.filetype) or vim.tbl_contains(nvim.disabled_buffer_types, vim.bo.buftype)

  vim.o.winwidth = ignored and vim.o.winminwidth or math.floor(vim.o.columns * WIDTH_RATIO)
end

--- Maximizes the current window, or restores the previous sizes if it already is.
function nvim.fn.maximize_window()
  if restore ~= nil then
    vim.cmd(restore)
    restore = nil

    return
  end

  restore = vim.fn.winrestcmd()

  vim.cmd("wincmd |")
  vim.cmd("wincmd _")
end

--- Equalizes the sizes of all windows.
function nvim.fn.equalize_windows()
  restore = nil

  vim.cmd("wincmd =")
end

function M.setup()
  vim.opt.equalalways = false
  vim.opt.winminwidth = 5

  set_winwidth()

  require("ck.setup").init({
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "w" }),
          function()
            nvim.fn.equalize_windows()
          end,
          desc = "balance open windows",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "m" }),
          function()
            nvim.fn.maximize_window()
          end,
          desc = "maximize current window",
        },
      }
    end,
    keymaps = function(_, _)
      ---@type KeymapMappings
      return {
        {
          "<C-w><Space>",
          function()
            nvim.fn.equalize_windows()
          end,
          desc = "balance open windows",
        },
        {
          "<C-w><CR>",
          function()
            nvim.fn.maximize_window()
          end,
          desc = "maximize current window",
        },
      }
    end,
    autocmds = function()
      ---@type Autocmds
      return {
        {
          event = { "WinEnter", "BufWinEnter", "FileType" },
          group = "_autowidth",
          pattern = "*",
          callback = function()
            set_winwidth()
          end,
        },
        {
          -- `winrestcmd()` addresses windows by number, so a layout change
          -- makes the saved sizes restore into the wrong windows.
          event = { "WinNew", "WinClosed" },
          group = "_autowidth",
          pattern = "*",
          callback = function()
            restore = nil
          end,
        },
        {
          event = "VimResized",
          group = "_auto_resize",
          pattern = "*",
          callback = function()
            nvim.fn.equalize_windows()
          end,
        },
      }
    end,
  })
end

return M
