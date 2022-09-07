-- https://github.com/akinsho/git-conflict.nvim
local M = {}

local extension_name = "git_conflict_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
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
      n = {
        ["co"] = { ":GitConflictChooseOurs<CR>", { desc = "Conflict - Choose Ours" } },
        ["ct"] = { ":GitConflictChooseTheirs<CR>", { desc = "Conflict - Choose Theirs" } },
        ["cb"] = { ":GitConflictChooseBoth<CR>", { desc = "Conflict - Choose Both" } },
        ["c0"] = { ":GitConflictChooseNone<CR>", { desc = "Conflict - Choose None" } },
        ["]n"] = { ":GitConflictNextConflict<CR>", { desc = "Conflict - Next" } },
        ["[n"] = { ":GitConflictPrevConflict<CR>", { desc = "Conflict - Previous" } },
        ["cq"] = { ":GitConflictListQf<CR>", { desc = "Conflict - Quick Fix" } },
      },
    },
  })
end

return M
