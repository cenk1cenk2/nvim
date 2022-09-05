-- https://github.com/akinsho/git-conflict.nvim

local setup = require "utils.setup"

local M = {}

local extension_name = "git_conflict_nvim"

function M.config()
  setup.define_extension(extension_name, true, {
    packer = function(config)
      return {
        "akinsho/git-conflict.nvim",
        config = function()
          require("utils.setup").packer_config "git_conflict_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = {
      default_mappings = false, -- disable buffer local mapping created by this plugin
      disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = { -- They must have background color, otherwise the default color will be used
        incoming = "DiffText",
        current = "DiffAdd",
      },
    },
    on_setup = function(config)
      require("git-conflict").setup(config.setup)
    end,
    keymaps = {
      ["co"] = { { "n" }, ":GitConflictChooseOurs<CR>", { desc = "Conflict - Choose Ours" } },
      ["ct"] = { { "n" }, ":GitConflictChooseTheirs<CR>", { desc = "Conflict - Choose Theirs" } },
      ["cb"] = { { "n" }, ":GitConflictChooseBoth<CR>", { desc = "Conflict - Choose Both" } },
      ["c0"] = { { "n" }, ":GitConflictChooseNone<CR>", { desc = "Conflict - Choose None" } },
      ["]n"] = { { "n" }, ":GitConflictNextConflict<CR>", { desc = "Conflict - Next" } },
      ["[n"] = { { "n" }, ":GitConflictPrevConflict<CR>", { desc = "Conflict - Previous" } },
      ["cq"] = { { "n" }, ":GitConflictListQf<CR>", { desc = "Conflict - Quick Fix" } },
    },
  })
end

return M
