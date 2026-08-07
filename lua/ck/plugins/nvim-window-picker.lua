-- https://github.com/s1n7ax/nvim-window-picker
local M = {}

M.name = "s1n7ax/nvim-window-picker"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "s1n7ax/nvim-window-picker",
      }
    end,
    setup = function()
      return {
        hint = "floating-big-letter",
        selection_chars = nvim.selection_chars:upper(),
        show_prompt = false,
        filter_rules = {
          bo = {
            filetype = vim.tbl_filter(function(ft)
              return not vim.tbl_contains(nvim.pickable_filetypes, ft)
            end, nvim.disabled_filetypes),
            buftype = nvim.disabled_buffer_types,
          },
          autoselect_one = true,
          include_current_win = true,
        },
        -- The default filter stack has no notion of floating windows, and a
        -- preview float carries no filetype to exclude it by — it reads as an
        -- ordinary unnamed buffer. Wrap that filter rather than replace it, so
        -- `filter_rules` stays in charge of everything else.
        filter_func = function(windows, rules)
          local filter = require("window-picker.filters.default-window-filter"):new()
          filter:set_config(rules)

          return vim.tbl_filter(function(win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end, filter:filter_windows(windows))
        end,
        highlights = {
          winbar = {
            focused = {
              fg = nvim.ui.colors.white,
              bg = nvim.ui.colors.green[100],
              bold = true,
            },
            unfocused = {
              fg = nvim.ui.colors.white,
              bg = nvim.ui.colors.yellow[100],
              bold = true,
            },
          },
        },
      }
    end,
    on_setup = function(c)
      M.opts = c

      require("window-picker").setup(c)
    end,
    wk = function(_, _, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ "<CR>" }),
          function()
            -- Relocating this buffer, so the window already holding it must not
            -- count as an answer.
            nvim.fn.open_in_picked_window(vim.api.nvim_get_current_buf(), { reuse = false })
          end,
          desc = "pick window",
        },
      }
    end,
  })
end

---
---@param config? table
---@return integer | nil
function nvim.fn.pick_window(config)
  return require("window-picker").pick_window(config)
end

--- The windows the picker would offer, run through its own filter chain so this
--- can never drift from what `pick_window` accepts. Returns nil when those
--- internals move under us, which callers must read as "cannot tell".
---
--- `window-picker.setup()` merges into a local rather than the config module, so
--- the module still holds plugin defaults — our own options have to be layered
--- back on here or the filtering silently differs from the real picker.
---
--- `builder:new()` returns the module table itself rather than an instance, so
--- `set_config` here mutates state the plugin shares. That is only safe because
--- `pick_window` sets its own config on every call; anything added later must
--- keep doing the same.
---@param config? table
---@return integer[] | nil
function nvim.fn.pickable_windows(config)
  local ok, windows = pcall(function()
    local resolved = vim.tbl_deep_extend("force", require("window-picker.config"), M.opts or {}, config or {})

    return require("window-picker.builder"):new():set_config(resolved):build():_get_windows()
  end)

  if not ok then
    return nil
  end

  return windows
end

--- Land `bufnr` in a sensible window: the one already showing it, else one
--- chosen with the picker. A window on the current tabpage wins over the same
--- buffer sitting in another tab. Pass `reuse = false` when the point is to
--- relocate the buffer rather than reach it, otherwise the window it is already
--- in answers the request and nothing moves.
---
--- Three outcomes, because the caller must treat them differently: a window id,
--- `false` when the user dismissed the picker, and nil when no window was worth
--- offering. Only the last one is the caller's cue to fall back — falling back
--- on a dismissal would perform the very jump the picker exists to intercept.
---@param bufnr integer
---@param opts? { reuse?: boolean, picker?: table }
---@return integer | false | nil
function nvim.fn.open_in_picked_window(bufnr, opts)
  opts = opts or {}

  local candidates = nvim.fn.pickable_windows(opts.picker)
  local win

  -- A window already showing the buffer only counts when the picker would have
  -- offered it anyway: an unfocusable float or a dock showing the same file is
  -- not somewhere to land. Other tabpages never count — reusing one drags the
  -- caller out of the layout they are working in.
  if opts.reuse ~= false then
    local tabpage = vim.api.nvim_get_current_tabpage()

    win = vim.iter(vim.fn.win_findbuf(bufnr)):find(function(w)
      return vim.api.nvim_win_get_tabpage(w) == tabpage and (candidates == nil or vim.tbl_contains(candidates, w))
    end)
  end

  local swap = win == nil

  if swap then
    -- Answer this ourselves rather than letting the picker warn about a state
    -- the caller is about to handle.
    if candidates ~= nil and #candidates == 0 then
      return nil
    end

    win = nvim.fn.pick_window(opts.picker)

    if win == nil then
      return false
    end
  end

  -- Mark before touching the window, while it still holds the position the
  -- caller is leaving — otherwise `<C-o>` comes back to the destination.
  vim.api.nvim_win_call(win, function()
    vim.cmd("normal! m'")
  end)

  if swap then
    vim.api.nvim_win_set_buf(win, bufnr)
  end

  vim.api.nvim_set_current_win(win)

  return win
end

return M
