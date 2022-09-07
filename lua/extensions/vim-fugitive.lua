-- https://github.com/tpope/vim-fugitive
local M = {}

local extension_name = "vim_fugitive"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "tpope/vim-fugitive",
        config = function()
          require("utils.setup").packer_config "vim_fugitive"
        end,
        disable = not config.active,
      }
    end,
    keymaps = {
      normal_mode = {
        ["gy"] = { [[:diffget //3<CR>]], { desc = "git ours" } },
        ["gY"] = { [[:diffget //2<CR>]], { desc = "git theirs" } },
      },
    },
    wk = {
      ["g"] = {
        a = { ":0Gclog<CR>", "buffer commits" },
        C = { ":Gdiffsplit<CR>", "diff split" },
        e = { ":Gedit<CR>", "edit version" },
        m = { ":Gvdiffsplit!<CR>", "merge view" },
      },
    },
  })
end

return M
