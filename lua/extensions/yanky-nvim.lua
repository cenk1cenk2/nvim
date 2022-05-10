local M = {}

local extension_name = "yanky_nvim"

function M.config()
  local yanky_ok, mapping = pcall(require, "yanky.telescope.mapping")

  if not yanky_ok then
    return
  end

  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      ring = {
        history_length = 10,
        storage = "shada",
        sync_with_numbered_registers = true,
      },
      system_clipboard = {
        sync_with_ring = true,
      },
      highlight = {
        on_put = true,
        on_yank = true,
        timer = 500,
      },
      preserve_cursor_position = {
        enabled = true,
      },
      picker = {
        telescope = {
          mappings = {
            default = mapping.put "p",
            i = {
              ["<c-p>"] = mapping.put "p",
              ["<c-k>"] = mapping.put "P",
            },
            n = {
              ["p"] = mapping.put "p",
              ["P"] = mapping.put "P",
            },
          },
        },
      },
    },
  }
end

function M.setup()
  local extension = require "yanky"

  extension.setup(lvim.extensions[extension_name].setup)

  -- vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", {})
  -- vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", {})
  -- vim.api.nvim_set_keymap("x", "p", "<Plug>(YankyPutAfter)", {})
  -- vim.api.nvim_set_keymap("x", "P", "<Plug>(YankyPutBefore)", {})
  -- vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", {})
  -- vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", {})
  -- vim.api.nvim_set_keymap("x", "gp", "<Plug>(YankyGPutAfter)", {})
  -- vim.api.nvim_set_keymap("x", "gP", "<Plug>(YankyGPutBefore)", {})
  -- vim.api.nvim_set_keymap("n", "y", "<Plug>(YankyYank)", {})
  -- vim.api.nvim_set_keymap("x", "y", "<Plug>(YankyYank)", {})

  vim.api.nvim_set_keymap("n", "gq", "<Plug>(YankyCycleForward)", {})
  vim.api.nvim_set_keymap("n", "gQ", "<Plug>(YankyCycleBackward)", {})

  pcall(function()
    require("telescope").load_extension "yank_history"

    lvim.builtin.which_key.mappings["y"] = { ":Telescope yank_history<CR>", "list yanky.nvim registers" }
  end)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
