local M = {}

--- Share of the total columns the focused window is grown to.
local WIDTH_RATIO = 0.25

---@type { cmd: string, layout: table }?
local restore = nil

--- 'winwidth' is global and Neovim applies it to the window being entered only
--- after `WinEnter` has run, so lowering it there is what keeps an ignored
--- window at the width it picked for itself.
local function set_winwidth()
  local ignored = vim.tbl_contains(nvim.disabled_filetypes, vim.bo.filetype) or vim.tbl_contains(nvim.disabled_buffer_types, vim.bo.buftype)

  vim.o.winwidth = ignored and vim.o.winminwidth or math.floor(vim.o.columns * WIDTH_RATIO)
end

--- Maximizes the current window, or restores the previous sizes if it already is.
---@param full? boolean also shrinks the fixed-size windows
function nvim.fn.maximize_window(full)
  --- `winrestcmd()` addresses windows by number, so the saved sizes only apply
  --- to the split layout they were taken from; floats are not part of it.
  if restore ~= nil and vim.deep_equal(restore.layout, vim.fn.winlayout()) then
    vim.cmd(restore.cmd)
    restore = nil

    return
  end

  restore = { cmd = vim.fn.winrestcmd(), layout = vim.fn.winlayout() }

  local fixed = vim.tbl_filter(function(win)
    return not full and (vim.wo[win].winfixwidth or vim.wo[win].winfixheight)
  end, vim.api.nvim_tabpage_list_wins(0))
  local sizes = vim.tbl_map(function(win)
    return { win = win, width = vim.api.nvim_win_get_width(win), height = vim.api.nvim_win_get_height(win) }
  end, fixed)

  vim.cmd("wincmd |")
  vim.cmd("wincmd _")

  for _, size in ipairs(sizes) do
    if vim.wo[size.win].winfixwidth then
      vim.api.nvim_win_set_width(size.win, size.width)
    end

    if vim.wo[size.win].winfixheight then
      vim.api.nvim_win_set_height(size.win, size.height)
    end
  end
end

--- Equalizes the sizes of all windows.
function nvim.fn.equalize_windows()
  restore = nil

  vim.cmd("wincmd =")
end

function M.setup()
  vim.opt.equalalways = false
  -- `:mksession` always writes a bare `set winheight=1 winwidth=1` epilogue but only
  -- guards it with `set winminwidth=0` for tabpages that hold splits, so anything
  -- above 1 makes split-less sessions fail to load with E592.
  vim.opt.winminwidth = 1

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
          desc = "toggle maximize current window",
        },
        {
          fn.wk_keystroke({ categories.ACTIONS, "M" }),
          function()
            nvim.fn.maximize_window(true)
          end,
          desc = "toggle maximize current window fully",
        },
      }
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<C-w>m",
          function()
            nvim.fn.maximize_window()
          end,
          desc = "toggle maximize current window",
          mode = { "n" },
        },
        {
          "<C-w>M",
          function()
            nvim.fn.maximize_window(true)
          end,
          desc = "toggle maximize current window fully",
          mode = { "n" },
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
