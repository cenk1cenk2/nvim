-- https://github.com/rcarriga/nvim-dap-ui

local setup = require "utils.setup"

local M = {}

local extension_name = "nvim_dap_ui"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "rcarriga/nvim-dap-ui",
        requires = { "mfussenegger/nvim-dap" },
        config = function()
          require("utils.setup").packer_config "nvim_dap_ui"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      icons = { expanded = "▾", collapsed = "▸" },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      -- Expand lines larger than the window
      -- Requires >= 0.7
      expand_lines = vim.fn.has "nvim-0.7",
      -- Layouts define sections of the screen to place windows.
      -- The position can be "left", "right", "top" or "bottom".
      -- The size specifies the height/width depending on position.
      -- Elements are the elements shown in the layout (in order).
      -- Layouts are opened in order so that earlier layouts take priority in window sizing.
      layouts = {
        {
          elements = {
            -- Provide as ID strings or tables with "id" and "size" keys
            { id = "watches", size = 0.2 },
            { id = "stacks", size = 0.2 },
            { id = "breakpoints", size = 0.2 },
            {
              id = "repl",
              size = 0.40, -- Can be float or integer > 1
            },
          },
          size = 40,
          position = "left",
        },
        {
          elements = { "scopes" },
          size = 15,
          position = "bottom",
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil, -- Can be integer or nil.
      },
    },
    on_setup = function(config)
      require("dapui").setup(config.setup)
    end,
  })
end

return M
