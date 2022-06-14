local M = {}

local extension_name = "cybu_nvim"

function M.config()
  lvim.extensions[extension_name] = { active = false, on_config_done = nil }

  lvim.extensions[extension_name] = vim.tbl_extend("force", lvim.extensions[extension_name], {
    keymap = {
      normal_mode = {
        ["<M-h>"] = [[:CybuPrev<CR>]],
        ["<M-l>"] = [[:CybuNext<CR>]],
      },
    },
    setup = {
      position = {
        relative_to = "editor", -- win, editor, cursor
        anchor = "center", -- topleft, topcenter, topright,
        -- centerleft, center, centerright,
        -- bottomleft, bottomcenter, bottomright
        vertical_offset = 10, -- vertical offset from anchor in lines
        horizontal_offset = 0, -- vertical offset from anchor in columns
        max_win_height = 5, -- height of cybu window in lines
        max_win_width = 0.5, -- integer for absolute in columns
        -- float for relative to win/editor width
      },
      style = {
        path = "relative", -- absolute, relative, tail (filename only)
        border = "rounded", -- single, double, rounded, none
        separator = " ", -- string used as separator
        prefix = "…", -- string used as prefix for truncated paths
        padding = 2, -- left & right padding in number of spaces
        devicons = {
          enabled = true, -- enable or disable web dev icons
          colored = true, -- enable color for web dev icons
        },
        highlights = { -- see highlights via :highlight
          current_buffer = "Visual", -- used for the current buffer
          adjacent_buffers = "Comment", -- used for buffers not in focus
          background = "Normal", -- used for the window background
        },
      },
      display_time = 1000, -- time the cybu window is displayed
      exclude = { -- filetypes, cybu will not be active
        "neo-tree",
        "fugitive",
        "qf",
      },
      fallback = function() end, -- arbitrary fallback function
    },
  })
end

function M.setup()
  local extension = require "cybu"

  extension.setup(lvim.extensions[extension_name].setup)

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymap)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
