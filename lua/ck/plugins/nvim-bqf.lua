-- https://github.com/kevinhwang91/nvim-bqf
local M = {}

M.name = "kevinhwang91/nvim-bqf"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "kevinhwang91/nvim-bqf",
        ft = { "qf" },
      }
    end,
    setup = function()
      return {
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = nvim.ui.icons.borderchars,
        },
        func_map = { vsplit = "", ptogglemode = "z,", stoggleup = "" },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      }
    end,
    on_setup = function(c)
      require("bqf").setup(c)

      M.route_mouse_open_through_the_picker()
    end,
  })
end

--- Send double-click on a quickfix entry through the same window picker as
--- `<CR>` and `o`.
---
--- The keymap cannot be taken the ordinary way: bqf installs it from inside a
--- `defer_fn(..., 50)` once its preview attaches, so anything bound at
--- `FileType` time is overwritten a moment later. Replacing the function its
--- mapping calls wins without racing that timer.
function M.route_mouse_open_through_the_picker()
  local ok, handler = pcall(require, "bqf.preview.handler")

  if not ok then
    return
  end

  local original = handler.mouseDoubleClick

  handler.mouseDoubleClick = function(mode)
    -- The fzf filter binds this same handler with a mode inside its own terminal
    -- buffer, where a click is choosing an fzf line, not a quickfix entry.
    if mode ~= nil then
      return original(mode)
    end

    require("ck.plugins.quicker-nvim").open_with_window_picker({ mouse = true })
  end
end

return M
