-- https://github.com/akinsho/bufferline.nvim
local M = {}

M.name = "akinsho/bufferline.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "akinsho/bufferline.nvim",
        lazy = false,
        -- event = "VeryLazy",
      }
    end,
    setup = function()
      ---@type bufferline.UserConfig
      return {
        highlights = {
          background = {},
          buffer_selected = {
            italic = false,
          },
        },
        options = {
          mode = "buffers", -- set to "tabs" to only show tabpages instead
          numbers = "none", -- can be "none" | "ordinal" | "buffer_id" | "both" | function
          close_command = function(bufnr, force)
            nvim.fn.close_buffer(bufnr, force)
          end, -- can be a string | function, see "Mouse actions"
          right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
          left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
          middle_mouse_command = function(bufnr)
            nvim.fn.close_buffer(bufnr)
          end, -- can be a string | function, see "Mouse actions"
          -- NOTE: this plugin is designed with this icon in mind,
          -- and so changing this is NOT recommended, this is intended
          -- as an escape hatch for people who cannot bear it for whatever reason
          indicator = {
            icon = nvim.ui.icons.ui.BoldLineLeft,
            style = "icon", -- can also be 'underline'|'none',
          },
          buffer_close_icon = nvim.ui.icons.ui.Close,
          modified_icon = nvim.ui.icons.git.FileModified,
          close_icon = nvim.ui.icons.ui.Close,
          left_trunc_marker = nvim.ui.icons.ui.ArrowCircleLeft,
          right_trunc_marker = nvim.ui.icons.ui.ArrowCircleRight,
          --- name_formatter can be used to change the buffer's label in the bufferline.
          --- Please note some names can/will break the
          --- bufferline so use this at your discretion knowing that it has
          --- some limitations that will *NOT* be fixed.
          max_name_length = 30,
          max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
          tab_size = 30,
          truncate_names = true, -- whether or not tab names should be truncated
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = M.diagnostics_indicator,
          -- NOTE: this will be called a lot so don't do any heavy processing here
          -- custom_filter = M.custom_filter,
          offsets = {},
          color_icons = true, -- whether or not to add the filetype icon highlights
          show_buffer_icons = true, -- disable filetype icons for buffers
          show_buffer_close_icons = false,
          show_close_icon = false,
          show_tab_indicators = true,
          persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
          -- can also be a table containing 2 custom separators
          -- [focused and unfocused]. eg: { '|', '|' }
          -- https://github.com/akinsho/bufferline.nvim/blob/main/doc/bufferline.txt#L194
          separator_style = "thick",
          enforce_regular_tabs = false,
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },
          sort_by = "insert_after_current",
        },
      }
    end,
    on_setup = function(c)
      require("bufferline").setup(c)
    end,
    keymaps = function()
      return {
        {
          "<M-l>",
          function()
            require("bufferline").cycle(1)
          end,
          desc = "next buffer",
          mode = { "n" },
        },
        {
          "<M-h>",
          function()
            require("bufferline").cycle(-1)
          end,
          desc = "previous buffer",
          mode = { "n" },
        },
        {
          "<M-k>",
          function()
            require("bufferline").move(1)
          end,
          desc = "move buffer to next",
          mode = { "n" },
        },
        {
          "<M-j>",
          function()
            require("bufferline").move(-1)
          end,
          desc = "move buffer to previous",
          mode = { "n" },
        },
      }
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.BUFFER, "b" }),
          function()
            require("bufferline").pick()
          end,
          desc = "pick buffer",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "B" }),
          function()
            require("bufferline").close_with_pick()
          end,
          desc = "pick buffer to close",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "x" }),
          function()
            nvim.fn.close_buffer()
          end,
          desc = "close current buffer",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "X" }),
          function()
            -- require("bufferline").close_others()
            local current = vim.api.nvim_get_current_buf()

            for _, e in ipairs(require("bufferline").get_elements().elements) do
              if current ~= e.id and not require("bufferline.groups")._is_pinned(e) then
                vim.schedule(function()
                  nvim.fn.close_buffer(e.id)
                end)
              end
            end

            require("bufferline.ui").refresh()
          end,
          desc = "close all buffers but this",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "D" }),
          function()
            require("bufferline.groups").action("ungrouped", "close")
          end,
          desc = "close unpinned tabs",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "H" }),
          function()
            require("bufferline").close_in_direction("left")
          end,
          desc = "close all buffers to the left",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "L" }),
          function()
            require("bufferline").close_in_direction("right")
          end,
          desc = "close all buffers to the right",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "p" }),
          function()
            require("bufferline.groups").toggle_pin()
          end,
          desc = "pin current buffer",
        },
        {
          fn.wk_keystroke({ categories.BUFFER, "P" }),
          function()
            require("bufferline.groups").action("pinned", "close")
          end,
          desc = "close pinned buffer group",
        },
      }
    end,
  })
end

function M.diagnostics_indicator(_, _, diagnostics, _)
  local result = {}
  local symbols = { error = nvim.ui.icons.diagnostics.Error, warning = nvim.ui.icons.diagnostics.Warning, info = nvim.ui.icons.diagnostics.Information }

  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. " " .. count)
    end
  end

  local text = table.concat(result, " ")

  return #text > 0 and text or ""
end

return M
