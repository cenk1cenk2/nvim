-- https://github.com/neoclide/coc.nvim
local M = {}

local extension_name = "coc"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
          require("utils.setup").packer_config "coc"
        end,
        disable = not config.active,
      }
    end,
    legacy_setup = {
      coc_start_at_startup = true,
      coc_suggest_disable = 1,
      coc_global_extensions = {
        "coc-lists",
        "coc-marketplace",
        "coc-gitignore",
        "coc-gist",
      },
    },
  })
end

return M
