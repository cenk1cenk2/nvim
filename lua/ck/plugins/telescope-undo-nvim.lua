-- https://github.com/debugloop/telescope-undo.nvim
local M = {}

M.name = "debugloop/telescope-undo.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "debugloop/telescope-undo.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope undo" },
      }
    end,
    on_setup = function()
      local telescope = require("telescope")
      telescope.load_extension("undo")

      telescope.setup({
        extensions = {
          undo = {
            use_delta = true,
            use_custom_command = nil, -- setting this implies `use_delta = false`. Accepted format is: { "bash", "-c", "echo '$DIFF' | delta" }
            side_by_side = false,
            diff_context_lines = vim.o.scrolloff,
            entry_format = "state #$ID, $STAT, $TIME",
            mappings = {
              i = {
                -- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
                -- you want to replicate these defaults and use the following actions. This means
                -- installing as a dependency of telescope in it's `requirements` and loading this
                -- extension from there instead of having the separate plugin definition as outlined
                -- above.
                ["<C-CR>"] = require("telescope-undo.actions").yank_additions,
                ["<S-CR>"] = require("telescope-undo.actions").yank_deletions,
                ["<CR>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      })
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.ACTIONS, "u" }),
          function()
            require("telescope").extensions.undo.undo()
          end,
          desc = "toggle undo tree",
        },
      }
    end,
  })
end

return M
