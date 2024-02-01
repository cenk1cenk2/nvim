-- https://github.com/nvim-telescope/telescope-github.nvim
local M = {}

local extension_name = "telescope_github"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-telescope/telescope-github.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope gh" },
      }
    end,
    on_setup = function()
      require("telescope").load_extension("gh")
    end,
    wk = function(_, categories)
      return {
        [categories.GIT] = {
          g = {
            I = { ":Telescope gh issues<CR>", "github issues" },
            P = { ":Telescope gh pull_request<CR>", "github pull requests" },
          },
        },
      }
    end,
  })
end

return M
