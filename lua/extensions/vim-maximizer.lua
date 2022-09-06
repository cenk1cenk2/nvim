local M = {}

local extension_name = "vim_maximizer"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "szw/vim-maximizer",
        config = function()
          require("utils.setup").packer_config "vim_maximizer"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      maximizer_set_default_mapping = 0,
    },
    on_done = function()
      require("utils.command").set_option { winminheight = 0, winminwidth = 0 }
    end,
    wk = {
      ["M"] = { ":MaximizerToggle<CR>", "maximize current window" },
    },
  })
end

return M
