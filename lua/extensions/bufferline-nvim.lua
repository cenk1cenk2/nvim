-- https://github.com/akinsho/bufferline.nvim
local M = {}

local extension_name = "bufferline_nvim"
local Log = require("lvim.core.log")

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "akinsho/bufferline.nvim",
        dependencies = {
          -- https://github.com/ojroques/nvim-bufdel
          "ojroques/nvim-bufdel",
        },
        -- https://github.com/akinsho/bufferline.nvim/issues/736
        commit = "efdf6628b2cbfde6417a11b6337c16154e6779c5",
        lazy = false,
        -- event = "VeryLazy",
      }
    end,
    setup = {
      highlights = {
        background = {
          -- gui = "italic",
        },
        buffer_selected = {
          italic = false,
        },
      },
      options = {
        mode = "buffers", -- set to "tabs" to only show tabpages instead
        numbers = "none", -- can be "none" | "ordinal" | "buffer_id" | "both" | function
        close_command = "BufferClose", -- can be a string | function, see "Mouse actions"
        right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
        left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
        middle_mouse_command = "BufferClose", -- can be a string | function, see "Mouse actions"
        -- NOTE: this plugin is designed with this icon in mind,
        -- and so changing this is NOT recommended, this is intended
        -- as an escape hatch for people who cannot bear it for whatever reason
        indicator = {
          icon = "▎",
          style = "icon", -- can also be 'underline'|'none',
        },
        buffer_close_icon = "",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        --- name_formatter can be used to change the buffer's label in the bufferline.
        --- Please note some names can/will break the
        --- bufferline so use this at your discretion knowing that it has
        --- some limitations that will *NOT* be fixed.
        name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
          -- remove extension from markdown files for example
          if buf.name:match("%.md") then
            return vim.fn.fnamemodify(buf.name, ":t:r")
          end
        end,
        max_name_length = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        tab_size = 20,
        truncate_names = true, -- whether or not tab names should be truncated
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = M.diagnostics_indicator,
        -- NOTE: this will be called a lot so don't do any heavy processing here
        custom_filter = M.custom_filter,
        offsets = {
          -- {
          --   filetype = "undotree",
          --   text = "Undotree",
          --   highlight = "PanelHeading",
          --   padding = 1,
          -- },
          -- {
          --   filetype = "NvimTree",
          --   text = "Explorer",
          --   highlight = "PanelHeading",
          --   padding = 1,
          -- },
          -- {
          --   filetype = "DiffviewFiles",
          --   text = "Diff View",
          --   highlight = "PanelHeading",
          --   padding = 1,
          -- },
          -- {
          --   filetype = "flutterToolsOutline",
          --   text = "Flutter Outline",
          --   highlight = "PanelHeading",
          -- },
          -- {
          --   filetype = "packer",
          --   text = "Packer",
          --   highlight = "PanelHeading",
          --   padding = 1,
          -- },
        },
        color_icons = true, -- whether or not to add the filetype icon highlights
        show_buffer_icons = true, -- disable filetype icons for buffers
        show_buffer_close_icons = true,
        show_close_icon = false,
        show_tab_indicators = true,
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { '|', '|' }
        separator_style = "thin",
        enforce_regular_tabs = false,
        sort_by = "id",
      },
    },
    on_setup = function(config)
      require("bufferline").setup(config.setup)

      require("bufdel").setup({
        next = "tabs", -- or 'cycle, 'alternate'
        quit = false, -- quit Neovim when last buffer is closed
      })
    end,
    commands = {
      {
        name = "BufferClose",
        fn = function()
          M.buf_kill()
        end,
      },
      {
        name = "BufferCloseAllButCurrent",
        fn = function()
          M.close_all_but_current()
        end,
      },
      {
        name = "BufferClosePinned",
        fn = function()
          M.close_pinned()
        end,
      },
      {
        name = "BufferCloseUnpinned",
        fn = function()
          M.close_unpinned()
        end,
      },
    },
    keymaps = {
      normal_mode = {
        ["<M-l>"] = ":BufferLineCycleNext<CR>",
        ["<M-j>"] = ":BufferLineMoveNext<CR>",
        ["<M-h>"] = ":BufferLineCyclePrev<CR>",
        ["<M-k>"] = ":BufferLineMovePrev<CR>",
        ["<C-q>"] = ":BufferClose<CR>",
        ["<C-Q>"] = ":BufferClose<CR>",
      },
    },
    wk = function(_, categories)
      return {
        [categories.BUFFER] = {
          ["b"] = { ":BufferLinePick<CR>", "pick buffer" },
          ["x"] = { ":BufferClose<CR>", "force close buffer" },
          ["X"] = { ":BufferCloseAllButCurrent<CR>", "close all buffers but this" },
          ["d"] = { ":BufferLinePickClose<CR>", "pick buffer to close" },
          ["D"] = { ":BufferCloseUnpinned<CR>", "close unpinned tabs" },
          ["y"] = { ":BufferLineCloseLeft<CR>", "close all buffers to the left" },
          ["Y"] = { ":BufferLineCloseRight<CR>", "close all buffers to the right" },
          ["p"] = { ":BufferLineTogglePin<CR>", "pin current buffer" },
          ["P"] = { ":BufferClosePinned<CR>", "close pinned buffer group" },
        },
      }
    end,
    autocmds = {
      {
        { "BufLeave" },
        {
          pattern = "{}",
          callback = function(args)
            if vim.api.nvim_buf_get_name(args.buf) == "" and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
              -- vim.bo.buftype = "nofile"
              vim.bo.bufhidden = "unload"
            end
          end,
          group = "_empty_buffer",
        },
      },
    },
  })
end

function M.is_ft(b, ft)
  return vim.bo[b].filetype == ft
end

function M.diagnostics_indicator(num, _, diagnostics, _)
  local result = {}
  local symbols = { error = lvim.ui.icons.diagnostics.Error, warning = lvim.ui.icons.diagnostics.Warning, info = lvim.ui.icons.diagnostics.Information }

  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. " " .. count)
    end
  end

  local text = table.concat(result, " ")

  return #text > 0 and text or ""
end

function M.custom_filter(buf, buf_nums)
  local logs = vim.tbl_filter(function(b)
    return M.is_ft(b, "log")
  end, buf_nums)
  if vim.tbl_isempty(logs) then
    return true
  end
  local tab_num = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr("$")
  local is_log = M.is_ft(buf, "log")
  if last_tab == 1 then
    return true
  end
  -- only show log buffers in secondary tabs
  return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

function M.close_all_but_current()
  local current = vim.api.nvim_get_current_buf()
  local buffers = require("bufferline.utils").get_valid_buffers()
  for _, bufnr in pairs(buffers) do
    if bufnr ~= current and not require("bufferline.groups").is_pinned({ id = bufnr }) then
      M.buf_kill(bufnr)
    end
  end
end

function M.close_pinned()
  local buffers = require("bufferline.utils").get_valid_buffers()
  for _, bufnr in pairs(buffers) do
    if require("bufferline.groups").is_pinned({ id = bufnr }) and bufnr then
      M.buf_kill(bufnr)
    end
  end
end

function M.close_unpinned()
  local buffers = require("bufferline.utils").get_valid_buffers()
  for _, bufnr in pairs(buffers) do
    if not require("bufferline.groups").is_pinned({ id = bufnr }) and bufnr then
      M.buf_kill(bufnr)
    end
  end
end

-- Common kill function for bdelete and bwipeout
-- credits: based on bbye and nvim-bufdel
---@param bufnr? number defaults to the current buffer
---@param force? boolean defaults to false
function M.buf_kill(bufnr, force)
  local bo = vim.bo
  local api = vim.api
  local fmt = string.format
  local fnamemodify = vim.fn.fnamemodify

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  local bufname = api.nvim_buf_get_name(bufnr)

  local callback = function(b, f)
    require("bufdel").delete_buffer_expr(b, f)
  end

  local is_pinned = require("bufferline.groups").is_pinned({ id = bufnr })

  if not force then
    local warning
    if bo[bufnr].modified or is_pinned then
      warning = fmt([[No write since last change for (%s)]], fnamemodify(bufname, ":t"))
    elseif is_pinned then
      warning = fmt([[Buffer is pinned (%s)]], fnamemodify(bufname, ":t"))
    elseif api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      warning = fmt([[Terminal %s will be killed]], bufname)
    end

    if warning then
      vim.ui.input({
        prompt = string.format([[%s. Close it anyway? [y]es or [n]o (default: no): ]], warning),
      }, function(choice)
        if not choice then
          return
        elseif choice:match("ye?s?") then
          callback(bufnr, true)
        end
      end)

      return
    end
  end

  callback(bufnr, false)
end

return M
