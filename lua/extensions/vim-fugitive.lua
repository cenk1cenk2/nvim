local M = {}

local extension_name = "vim_fugitive"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    keymaps = {
      normal_mode = {
        ["gy"] = { [[:diffget //3<CR>]], { desc = "git ours" } },
        ["gY"] = { [[:diffget //2<CR>]], { desc = "git theirs" } },
      },
    },
  }
end

function M.setup()
  require("lvim.keymappings").load(lvim.extensions[extension_name].keymaps)

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done()
  end
end

return M
