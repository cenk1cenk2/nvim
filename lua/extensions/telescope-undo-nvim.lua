-- https://github.com/debugloop/telescope-undo.nvim
local M = {}

local extension_name = "telescope_undo_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "debugloop/telescope-undo.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = { "Telescope undo" },
      }
    end,
    configure = function(_, fn)
      fn.append_to_setup("telescope", {
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
    on_setup = function()
      local telescope = require("telescope")
      telescope.load_extension("undo")
    end,
    wk = function(_, categories)
      return {
        [categories.ACTIONS] = {
          ["u"] = {
            function()
              require("telescope").extensions.undo.undo()
            end,
            "toggle undo tree",
          },
        },
      }
    end,
  })
end

return M
