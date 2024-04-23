-- https://github.com/akinsho/bufferline.nvim
local M = {}

local extension_name = "bufferline_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "akinsho/bufferline.nvim",
        lazy = false,
        -- event = "VeryLazy",
      }
    end,
    setup = function()
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
            lvim.fn.close_buffer(bufnr, force)
          end, -- can be a string | function, see "Mouse actions"
          right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
          left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
          middle_mouse_command = function(bufnr)
            lvim.fn.close_buffer(bufnr)
          end, -- can be a string | function, see "Mouse actions"
          -- NOTE: this plugin is designed with this icon in mind,
          -- and so changing this is NOT recommended, this is intended
          -- as an escape hatch for people who cannot bear it for whatever reason
          indicator = {
            icon = lvim.ui.icons.ui.BoldLineLeft,
            style = "icon", -- can also be 'underline'|'none',
          },
          buffer_close_icon = lvim.ui.icons.ui.Close,
          modified_icon = lvim.ui.icons.git.FileModified,
          close_icon = lvim.ui.icons.ui.Close,
          left_trunc_marker = lvim.ui.icons.ui.ArrowCircleLeft,
          right_trunc_marker = lvim.ui.icons.ui.ArrowCircleRight,
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
    on_setup = function(config)
      require("bufferline").setup(config.setup)
    end,
    keymaps = {
      {
        { "n" },

        ["<M-S-l>"] = {
          function()
            vim.cmd([[tabnext]])
          end,
          { desc = "next tab" },
        },
        ["<M-S-h>"] = {
          function()
            vim.cmd([[tabprevious]])
          end,
          { desc = "prev tab" },
        },

        ["<M-l>"] = {
          function()
            require("bufferline").cycle(1)
          end,
          { desc = "next buffer" },
        },
        ["<M-h>"] = {
          function()
            require("bufferline").cycle(-1)
          end,
          { desc = "previous buffer" },
        },
        ["<M-k>"] = {
          function()
            require("bufferline").move(1)
          end,
          { desc = "move buffer to next" },
        },
        ["<M-j>"] = {
          function()
            require("bufferline").move(-1)
          end,
          { desc = "move buffer to previous" },
        },
      },
    },
    wk = function(_, categories)
      return {
        [categories.BUFFER] = {
          ["b"] = {
            function()
              require("bufferline").pick()
            end,
            "pick buffer",
          },
          ["B"] = {
            function()
              require("bufferline").close_with_pick()
            end,
            "pick buffer to close",
          },
          ["X"] = {
            function()
              -- require("bufferline").close_others()
              local current = vim.api.nvim_get_current_buf()

              for _, e in ipairs(require("bufferline").get_elements().elements) do
                if current ~= e.id and not require("bufferline.groups")._is_pinned(e) then
                  vim.schedule(function()
                    lvim.fn.close_buffer(e.id)
                  end)
                end
              end

              require("bufferline.ui").refresh()
            end,
            "close all buffers but this",
          },
          ["D"] = {
            function()
              require("bufferline.groups").action("ungrouped", "close")
            end,
            "close unpinned tabs",
          },
          ["y"] = {
            function()
              require("bufferline").close_in_direction("left")
            end,
            "close all buffers to the left",
          },
          ["Y"] = {
            function()
              require("bufferline").close_in_direction("right")
            end,
            "close all buffers to the right",
          },
          ["p"] = {
            function()
              require("bufferline.groups").toggle_pin(0)
            end,
            "pin current buffer",
          },
          ["P"] = {
            function()
              require("bufferline.groups").action("pinned", "close")
            end,
            "close pinned buffer group",
          },
        },
      }
    end,
  })
end

function M.diagnostics_indicator(_, _, diagnostics, _)
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

return M
