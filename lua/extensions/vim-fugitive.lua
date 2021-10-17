local M = {}

local extension_name = "vim_fugitive"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = { normal_mode = { ["gy"] = [[:diffget //3<CR>]], ["gx"] = [[:diffget //2<CR>]] } },
  }
end

function M.setup()
  require("utils.command").wrap_to_command {
    { "GDiffCompare", 'lua require("plugin-configurations.fugitive").GDiffCompare()' },
  }
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
