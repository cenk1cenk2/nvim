-- https://github.com/HiPhish/rainbow-delimiters.nvim
local M = {}

M.name = "HiPhish/rainbow-delimiters.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      ---@type rainbow_delimiters.config
      return {
        disable = nvim.disabled_filetypes,
        -- Which query to use for finding delimiters
        query = {
          [""] = "rainbow-delimiters",
          jsx = "rainbow-parens",
          tsx = "rainbow-parens",
          vue = "rainbow-parens",
          svelte = "rainbow-parens",
          html = "rainbow-parens",
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
    on_setup = function(c)
      require("rainbow-delimiters.setup").setup(c)
    end,
  })
end

return M
