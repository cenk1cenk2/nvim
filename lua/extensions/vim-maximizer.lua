local M = {}

local extension_name = "vim_maximizer"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "szw/vim-maximizer",
        cmd = { "MaximizerToggle" },
      }
    end,
    legacy_setup = {
      maximizer_set_default_mapping = 0,
    },
    on_done = function()
      require("utils.command").set_option({ winminheight = 0, winminwidth = 0 })
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["M"] = { ":MaximizerToggle<CR>", "maximize current window" },
        },
      }
    end,
  })
end

return M
