-- https://github.com/stevearc/quicker.nvim
local M = {}

M.name = "stevearc/quicker.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/quicker.nvim",
        ft = { "qf" },
      }
    end,
    setup = function()
      ---@type quicker.SetupOptions
      return {
        edit = {
          enabled = true,
        },
        type_icons = {
          E = nvim.ui.icons.diagnostics.Error,
          W = nvim.ui.icons.diagnostics.Warning,
          I = nvim.ui.icons.diagnostics.Information,
          N = nvim.ui.icons.diagnostics.Dot,
          H = nvim.ui.icons.diagnostics.Hint,
        },
        keys = {
          {
            ">",
            function()
              require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
            end,
            desc = "Expand quickfix context",
          },
          {
            "<",
            function()
              require("quicker").collapse()
            end,
            desc = "Collapse quickfix context",
          },
          {
            "R",
            function()
              require("quicker").refresh()
            end,
            desc = "Refresh quickfix context",
          },
          -- The open-into-an-existing-window family, taken back from nvim-bqf so
          -- every one of them lands where the picker says. Its split and tab
          -- maps are left alone — those create the window themselves.
          {
            "<CR>",
            function()
              M.open_with_window_picker()
            end,
            desc = "Open entry in a picked window",
          },
          {
            "o",
            function()
              M.open_with_window_picker({ close = true })
            end,
            desc = "Open entry in a picked window and close the list",
          },
          {
            "<2-LeftMouse>",
            function()
              M.open_with_window_picker({ mouse = true })
            end,
            desc = "Open clicked entry in a picked window",
          },
        },
        max_filename_width = function()
          return math.floor(math.min(40, vim.o.columns / 8))
        end,
      }
    end,
    on_setup = function(c)
      require("quicker").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<C-y>",
          function()
            require("quicker").toggle({ focus = true })
          end,
          desc = "quickfix [quicker]",
          mode = { "n", "v", "x" },
        },

        {
          "<C-S-Y>",
          function()
            require("quicker").toggle({ focus = true, loclist = true })
          end,
          desc = "location list [quicker]",
          mode = { "n", "v", "x" },
        },
      }
    end,
  })
end

--- Open the entry under the cursor in a window chosen with the window picker.
---
--- `:cc` obeys `switchbuf=uselast`, so it lands in whatever window happened to
--- be focused when the list was filled — regularly a sidebar, a terminal, or an
--- edgy dock. The picker's filters already exclude those, and `autoselect_one`
--- keeps the single-window case silent.
---@param opts? { close?: boolean, mouse?: boolean }
function M.open_with_window_picker(opts)
  opts = opts or {}

  local list_win = vim.api.nvim_get_current_win()

  if opts.mouse then
    local pos = vim.fn.getmousepos()

    if pos.winid ~= list_win then
      return
    end

    vim.api.nvim_win_set_cursor(list_win, { pos.line, 0 })
  end

  local loclist = vim.fn.getwininfo(list_win)[1].loclist == 1
  local idx = vim.fn.line(".")
  local items = loclist and vim.fn.getloclist(list_win) or vim.fn.getqflist()
  local item = items[idx]

  -- Context lines added by `quicker.expand()` are entries with no location.
  if item == nil or item.valid == 0 or not vim.api.nvim_buf_is_valid(item.bufnr) then
    return
  end

  local win = nvim.fn.open_in_picked_window(item.bufnr)

  -- Picker dismissed. Falling back to `:cc` here would land the file in the
  -- window the picker was asked to avoid, so honour the dismissal instead.
  if win == false then
    return
  end

  -- Nothing worth offering — fall back to vim's own jump rather than swallowing
  -- the keystroke.
  if win == nil then
    vim.cmd(("%d%s"):format(idx, loclist and "ll" or "cc"))

    return
  end

  -- Keep the list's cursor in sync so a following `:cnext` continues from here.
  if loclist then
    vim.fn.setloclist(list_win, {}, "a", { idx = idx })
  else
    vim.fn.setqflist({}, "a", { idx = idx })
  end

  -- A pinned window can restore its own buffer the moment it takes focus, and
  -- placing the cursor for an entry that is no longer displayed errors out.
  if vim.api.nvim_win_get_buf(win) ~= item.bufnr then
    return
  end

  local lnum = math.min(math.max(item.lnum, 1), vim.api.nvim_buf_line_count(item.bufnr))
  vim.api.nvim_win_set_cursor(win, { lnum, math.max(item.col - 1, 0) })
  vim.cmd("normal! zvzz")

  if opts.close and vim.api.nvim_win_is_valid(list_win) then
    vim.api.nvim_win_close(list_win, true)
  end
end

return M
