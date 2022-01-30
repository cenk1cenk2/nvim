local M = {}

local extension_name = "nvim_lightbulb"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      -- LSP client names to ignore
      -- Example: {"sumneko_lua", "null-ls"}
      ignore = {},
      sign = {
        enabled = true,
        -- Priority of the gutter sign
        priority = 100,
      },
      float = {
        enabled = false,
        -- Text to show in the popup float
        text = "💡",
        -- Available keys for window options:
        -- - height     of floating window
        -- - width      of floating window
        -- - wrap_at    character to wrap at for computing height
        -- - max_width  maximal width of floating window
        -- - max_height maximal height of floating window
        -- - pad_left   number of columns to pad contents at left
        -- - pad_right  number of columns to pad contents at right
        -- - pad_top    number of lines to pad contents at top
        -- - pad_bottom number of lines to pad contents at bottom
        -- - offset_x   x-axis offset of the floating window
        -- - offset_y   y-axis offset of the floating window
        -- - anchor     corner of float to place at the cursor (NW, NE, SW, SE)
        -- - winblend   transparency of the window (0-100)
        win_opts = {},
      },
      virtual_text = {
        enabled = false,
        -- Text to show at virtual text
        text = "💡",
        -- highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference
        hl_mode = "replace",
      },
      status_text = {
        enabled = false,
        -- Text to provide when code actions are available
        text = "💡",
        -- Text to provide when no actions are available
        text_unavailable = "",
      },
    },
  }
end

function M.setup()
  local extension = require "nvim-lightbulb"

  extension.update_lightbulb(lvim.extensions[extension_name].setup)

  vim.cmd [[autocmd CursorHold,CursorHoldI * lua require'modules.lightbulb'.update_lightbulb()]]
  vim.fn.sign_define("LightBulbSign", { text = "💡", texthl = "", linehl = "", numhl = "" })

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
