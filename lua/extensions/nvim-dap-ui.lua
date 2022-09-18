-- https://github.com/rcarriga/nvim-dap-ui
local M = {}

local extension_name = "nvim_dap_ui"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "rcarriga/nvim-dap-ui",
        requires = { "mfussenegger/nvim-dap" },
        after = { "nvim-dap" },
        config = function()
          require("utils.setup").packer_config "nvim_dap_ui"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        dap_ui = require "dapui",
      }
    end,
    on_init = function(config)
      config.set_store("setup", false)
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
      expand_lines = true,
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
      if config.get_store "setup" then
        return
      end

      require("dapui").setup(config.setup)
      config.set_store("setup", true)
    end,
    wk = function(config)
      local dap_ui = config.inject.dap_ui

      return {
        ["d"] = {
          u = {
            function()
              dap_ui.toggle()
            end,
            "toggle ui",
          },
          K = {
            function()
              dap_ui.float_element()
            end,
            "floating element",
          },
        },
      }
    end,
  })
end

return M
