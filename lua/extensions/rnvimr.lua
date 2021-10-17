local M = {}

local extension_name = "rnvimr"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = { ["<F5>"] = ":RnvimrToggle<CR>" },
      term_mode = { ["<F5>"] = "<C-\\><C-n>:RnvimrToggle<CR>" },
    },
  }
end

function M.setup()
  vim.g.rnvimr_draw_border = 1
  vim.g.rnvimr_pick_enable = 1
  vim.g.rnvimr_bw_enable = 1
  vim.g.rnvimr_enable_ex = 0
  vim.g.rnvimr_hide_gitignore = 0
  vim.g.rnvimr_ranger_cmd = 'ranger --cmd="set column_ratios 1,1"'
  vim.g.rnvimr_presets = { { width = 0.900, height = 0.900 } }

  lvim.builtin.which_key.mappings["r"] = { ":RnvimrToggle<CR>", "ranger" }

  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  -- vim.g.loaded_netrw = 1
  -- vim.g.netrw_loaded_netrwPlugin = 1

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
