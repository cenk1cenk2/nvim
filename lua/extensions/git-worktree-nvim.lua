-- https://github.com/ThePrimeagen/git-worktree.nvim
local M = {}

M.name = "ThePrimeagen/git-worktree.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
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
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.GIT, "W" }),
          group = "worktree",
        },
        {
          fn.wk_keystroke({ categories.GIT, "W", "f" }),
          function()
            require("telescope").extensions.git_worktree.git_worktrees()
          end,
          desc = "git worktrees",
        },
        {
          fn.wk_keystroke({ categories.GIT, "W", "c" }),
          function()
            require("telescope").extensions.git_worktree.create_git_worktree()
          end,
          desc = "create git worktree",
        },
      }
    end,
  })
end

return M
