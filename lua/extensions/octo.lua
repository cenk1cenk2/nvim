-- https://github.com/pwntester/octo.nvim
local M = {}

M.name = "pwntester/octo.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "pwntester/octo.nvim",
        cmd = { "Octo" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("octo").setup(config.setup)
    end,
  })
end

return M
