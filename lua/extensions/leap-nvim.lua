-- https://github.com/ggandor/leap.nvim
-- https://github.com/ggandor/flit.nvim
-- https://github.com/ggandor/leap-spooky.nvim
-- https://github.com/ggandor/leap-ast.nvim
local M = {}

local extension_name = "leap_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "ggandor/leap.nvim",
        dependencies = {
          {
            "ggandor/flit.nvim",
            keys = { "f", "F", "t", "T" },
          },
          {
            "ggandor/leap-spooky.nvim",
          },
          {
            "ggandor/leap-ast.nvim",
          },
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
          highlight_unlabeled_phase_one_targets = false,
          max_highlighted_traversal_targets = nil,
          case_sensitive = false,
          equivalence_classes = { " \t\r\n" },
          -- substitute_chars = {},
          -- safe_labels = chars,
          -- labels = chars,
          special_keys = {
            repeat_search = "<enter>",
            next_phase_one_target = "<enter>",
            next_target = { "<enter>", ";" },
            prev_target = { "<tab>", "," },
            next_group = "<space>",
            prev_group = "<tab>",
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
          paste_on_remote_yank = true,
        },
        flit = {
          keys = { f = "f", F = "F", t = "t", T = "T" },
          -- A string like "nv", "nvo", "o", etc.
          labeled_modes = "v",
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
      local function get_line_starts(winid)
        local wininfo = vim.fn.getwininfo(winid)[1]
        local cur_line = vim.fn.line(".")

        -- Get targets.
        local targets = {}
        local lnum = wininfo.topline
        while lnum <= wininfo.botline do
          local fold_end = vim.fn.foldclosedend(lnum)
          -- Skip folded ranges.
          if fold_end ~= -1 then
            lnum = fold_end + 1
          else
            if lnum ~= cur_line then
              table.insert(targets, { pos = { lnum, 1 } })
            end
            lnum = lnum + 1
          end
        end
        -- Sort them by vertical screen distance from cursor.
        local cur_screen_row = vim.fn.screenpos(winid, cur_line, 1)["row"]
        local function screen_rows_from_cur(t)
          local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
          return math.abs(cur_screen_row - t_screen_row)
        end
        table.sort(targets, function(t1, t2)
          return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
        end)

        if #targets >= 1 then
          return targets
        end
      end

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

          ["SS"] = {
            function()
              local winid = vim.api.nvim_get_current_win()
              require("leap").leap({
                target_windows = { winid },
                targets = get_line_starts(winid),
              })
            end,
            { desc = "leap to line." },
          },

          ["ss"] = {
            function()
              require("leap-ast").leap()
            end,
            { desc = "leap with treesitter." },
          },
        },
      }
    end,
  })
end

return M
