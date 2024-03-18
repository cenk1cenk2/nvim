-- https://github.com/rcarriga/nvim-dap-ui
local M = {}

local extension_name = "nvim_dap_ui"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "mfussenegger/nvim-dap",
          "nvim-neotest/nvim-nio",
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "dapui_breakpoints",
        "dapui_stacks",
        "dapui_watches",
        "dapui_scopes",
        "dapui_repl",
      })
    end,
    setup = function()
      return {
        icons = { expanded = lvim.ui.icons.ui.ChevronShortDown, collapsed = lvim.ui.icons.ui.ChevronShortRight },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>", "O" },
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
              {
                id = "watches",
                size = 0.2,
              },
              {
                id = "stacks",
                size = 0.5,
              },
              {
                id = "breakpoints",
                size = 0.3,
              },
            },
            size = 60,
            position = "right",
          },
          {
            elements = {
              {
                id = "repl",
                size = 0.5,
              },
              {
                id = "scopes",
                size = 0.5, -- Can be float or integer > 1
              },
            },
            size = 20,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil, -- These can be integers or a float between 0 and 1.
          max_width = nil, -- Floats will be treated as percentage of your screen.
          border = lvim.ui.border, -- Border style. Can be lvim.ui.border, "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
        },
      }
    end,
    on_setup = function(config)
      require("dapui").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.DEBUG] = {
          u = {
            function()
              require("dapui").toggle()
            end,
            "toggle ui",
          },
          U = {
            function()
              require("dapui").float_element()
            end,
            "floating element",
          },
        },
      }
    end,
  })
end

return M
