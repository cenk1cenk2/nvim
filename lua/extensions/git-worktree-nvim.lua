-- https://github.com/ThePrimeagen/git-worktree.nvim
local M = {}

local extension_name = "ThePrimeagen/git-worktree.nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "ThePrimeagen/git-worktree.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
      }
    end,
    setup = function()
      return {}
    end,
    on_setup = function(config)
      require("git-worktree").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension("git_worktree")
    end,
    wk = function(_, categories)
      return {
        [categories.GIT] = {
          W = {
            name = "worktree",
            f = {
              function()
                require("telescope").extensions.git_worktree.git_worktrees()
              end,
              "git worktrees",
            },
            c = {
              function()
                require("telescope").extensions.git_worktree.create_git_worktree()
              end,
              "create git worktree",
            },
          },
        },
      }
    end,
  })
end

return M
