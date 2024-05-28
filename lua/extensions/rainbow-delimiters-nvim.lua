-- https://github.com/HiPhish/rainbow-delimiters.nvim
local M = {}

local extension_name = "rainbow_delimiters_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        -- https://github.com/HiPhish/rainbow-delimiters.nvim/pull/120
        "Danielkonge/rainbow-delimiters.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      return {
        disable = lvim.disabled_filetypes,
        -- Which query to use for finding delimiters
        query = {
          [""] = "rainbow-delimiters",
          jsx = "rainbow-parens",
          tsx = "rainbow-parens",
          vue = "rainbow-parens",
          svelte = "rainbow-parens",
          html = "",
        },
        -- Highlight the entire buffer all at once
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        highlight = {
          "TSRainbow1",
          "TSRainbow2",
          "TSRainbow3",
          "TSRainbow4",
        },
      }
    end,
    on_setup = function(config)
      require("rainbow-delimiters.setup").setup(config.setup)
    end,
  })
end

return M
