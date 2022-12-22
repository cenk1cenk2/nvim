-- https://github.com/rcarriga/nvim-dap-ui
local M = {}

local extension_name = "nvim_dap_ui"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
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
            {
              id = "watches",
              size = 0.2,
            },
            {
              id = "stacks",
              size = 0.6,
            },
            {
              id = "breakpoints",
              size = 0.2,
            },
          },
          size = 40,
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
    },
    on_setup = function(config)
      if config.get_store("setup") then
        return
      end

      require("dapui").setup(config.setup)
      config.set_store("setup", true)
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
          K = {
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
