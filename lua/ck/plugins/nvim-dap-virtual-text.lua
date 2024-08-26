-- https://github.com/theHamsta/nvim-dap-virtual-text
local M = {}

M.name = "theHamsta/nvim-dap-virtual-text"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "theHamsta/nvim-dap-virtual-text",
        cmd = { "DapVirtualTextToggle" },
        keys = { "<Space>d" },
      }
    end,
    setup = function()
      ---@type nvim_dap_virtual_text_options
      return {
        enabled = true, -- enable this plugin (the default)
        enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
        highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        show_stop_reason = true, -- show stop reason when stopped for exceptions
        commented = false, -- prefix virtual text with comment string
        only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
        all_references = false, -- show virtual text on all all references of the variable (not only definitions)
        filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
        -- experimental features:
        virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
        all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil,
      }
    end,
    on_setup = function(c)
      require("nvim-dap-virtual-text").setup(c)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.DEBUG, "v" }),
          function()
            vim.cmd([[DapVirtualTextToggle]])
          end,
          desc = "toggle debugging virtual text",
        },
      }
    end,
  })
end

return M
