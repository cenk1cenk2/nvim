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
          },
          autoselect_one = true,
          include_current_win = true,
        },
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
      require("window-picker").setup(c)
    end,
    wk = function(_, _, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ "<CR>" }),
          function()
            local id = nvim.fn.pick_window()

            if id then
              local win = vim.api.nvim_get_current_win()
              local buf = vim.api.nvim_get_current_buf()

              if id ~= win then
                vim.api.nvim_set_current_win(id)
                vim.api.nvim_set_current_buf(buf)
              end
            end
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

return M
