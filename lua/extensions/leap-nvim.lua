-- https://github.com/ggandor/leap.nvim
-- https://github.com/ggandor/flit.nvim
-- https://github.com/ggandor/leap-spooky.nvim
-- https://github.com/ggandor/leap-ast.nvim
-- https://github.com/yutkat/leap-word.nvim
local M = {}

local extension_name = "leap_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "ggandor/leap.nvim",
        keys = { "f", "F", "t", "T" },
        dependencies = {
          {
            "ggandor/flit.nvim",
          },
          { "ggandor/leap-spooky.nvim" },
          -- {
          --   "ggandor/leap-ast.nvim",
          -- },
          { "yutkat/leap-word.nvim" },
        },
      }
    end,
    setup = function()
      local chars = {}
      for i = 1, #lvim.selection_chars do
        local c = lvim.selection_chars:sub(i, i)

        table.insert(chars, c)
      end

      return {
        leap = {
          max_phase_one_targets = nil,
          highlight_unlabeled_phase_one_targets = true,
          max_highlighted_traversal_targets = 10,
          case_sensitive = false,
          equivalence_classes = { " \t\r\n" },
          substitute_chars = {},
          safe_labels = chars,
          labels = chars,
          special_keys = {
            repeat_search = "<enter>",
            next_phase_one_target = "<enter>",
            next_target = { "<enter>" },
            prev_target = { "<backspace>" },
            next_group = "<enter>",
            prev_group = "<backspace>",
            multi_accept = "<enter>",
            multi_revert = "<backspace>",
          },
        },
        spooky = {
          affixes = {
            -- These will generate mappings for all native text objects, like:
            -- (ir|ar|iR|aR|im|am|iM|aM){obj}.
            -- Special line objects will also be added, by repeating the affixes.
            -- E.g. `yrr<leap>` and `ymm<leap>` will yank a line in the current
            -- window.
            -- r - cursor doesn't move to the targeted position
            -- m - cursor moves to the targeted position
            -- You can also use 'rest' & 'move' as mnemonics.
            remote = { window = "r", cross_window = "R" },
            magnetic = { window = "m", cross_window = "M" },
          },
          -- If this option is set to true, the yanked text will automatically be pasted
          -- at the cursor position if the unnamed register is in use.
          paste_on_remote_yank = false,
        },
        flit = {
          keys = { f = "f", F = "F", t = "t", T = "T" },
          -- A string like "nv", "nvo", "o", etc.
          labeled_modes = "nvo",
          multiline = true,
          -- Like `leap`s similar argument (call-specific overrides).
          -- E.g.: opts = { equivalence_classes = {} }
          opts = {},
        },
      }
    end,
    on_setup = function(config)
      require("leap").setup(config.setup.leap)
      require("leap-spooky").setup(config.setup.spooky)
      require("flit").setup(config.setup.flit)
    end,
    -- on_done = function()
    -- require("leap").add_default_mappings()
    -- end,
    keymaps = function()
      return {
        n = {
          ["s"] = {
            function()
              require("leap").leap({ backward = false })
            end,
            { desc = "leap with 2 chars." },
          },

          ["S"] = {
            function()
              require("leap").leap({ backward = true })
            end,
            { desc = "leap with 2 backwards chars." },
          },

          ["ss"] = {
            function()
              require("leap").leap({
                targets = require("leap-word").get_forward_words(1),
              })
            end,
            { desc = "leap to word." },
          },

          ["SS"] = {
            function()
              require("leap").leap({
                targets = require("leap-word").get_backward_words(1),
              })
            end,
            { desc = "leap to word backward." },
          },
        },
      }
    end,
  })
end

return M
