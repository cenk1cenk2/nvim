-- https://github.com/nvim-telescope/telescope-github.nvim
local M = {}

M.name = "nvim-telescope/telescope-github.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-telescope/telescope-github.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope gh" },
      }
    end,
    on_setup = function()
      require("telescope").load_extension("gh")
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "g", "I" }),
          function()
            require("telescope").extensions.gh.issues()
          end,
          desc = "github issues",
        },
        {
          fn.wk_keystroke({ categories.GIT, "g", "P" }),
          function()
            require("telescope").extensions.gh.pull_requests()
          end,
          desc = "github pull requests",
        },
      }
    end,
  })
end

return M
