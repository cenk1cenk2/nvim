-- https://github.com/sindrets/diffview.nvim
local M = {}

local extension_name = "diffview"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "sindrets/diffview.nvim",
        config = function()
          require("utils.setup").packer_config "diffview"
        end,
        disable = not config.active,
      }
    end,
    to_inject = function()
      return {
        actions = require "diffview.actions",
      }
    end,
    setup = function(config)
      local actions = config.inject.actions

      return {
        diff_binaries = false, -- Show diffs for binaries
        use_icons = true, -- Requires nvim-web-devicons
        file_panel = { win_config = { width = 35 } },
        view = {
          -- Configure the layout and behavior of different types of views.
          -- Available layouts:
          --  'diff1_plain'
          --    |'diff2_horizontal'
          --    |'diff2_vertical'
          --    |'diff3_horizontal'
          --    |'diff3_vertical'
          --    |'diff3_mixed'
          --    |'diff4_mixed'
          -- For more info, see |diffview-config-view.x.layout|.
          default = {
            -- Config for changed files, and staged files in diff views.
            layout = "diff2_horizontal",
          },
          merge_tool = {
            -- Config for conflicted files in diff views during a merge or rebase.
            layout = "diff3_horizontal",
            disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
          },
          file_history = {
            -- Config for changed files in file history views.
            layout = "diff2_horizontal",
          },
        },
        key_bindings = {
          -- The `view` bindings are active in the diff buffers, only when the current
          -- tabpage is a Diffview.
          view = {
            ["<tab>"] = actions.select_next_entry, -- Open the diff for the next file
            ["<s-tab>"] = actions.select_prev_entry, -- Open the diff for the previous file
            ["gf"] = actions.goto_file, -- Open the file in a new split in the previous tabpage
            ["<C-w><C-f>"] = actions.goto_file_split, -- Open the file in a new split
            ["<C-w>gf"] = actions.goto_file_tab, -- Open the file in a new tabpage
            ["f"] = actions.focus_files, -- Bring focus to the file panel
            ["F"] = actions.toggle_files, -- Toggle the file panel.
            ["g<C-x>"] = actions.cycle_layout, -- Cycle through available layouts.
            ["[n"] = actions.prev_conflict, -- In the merge_tool: jump to the previous conflict
            ["]n"] = actions.next_conflict, -- In the merge_tool: jump to the next conflict
            ["co"] = actions.conflict_choose "ours", -- Choose the OURS version of a conflict
            ["ct"] = actions.conflict_choose "theirs", -- Choose the THEIRS version of a conflict
            ["cb"] = actions.conflict_choose "base", -- Choose the BASE version of a conflict
            ["ca"] = actions.conflict_choose "all", -- Choose all the versions of a conflict
            ["cn"] = actions.conflict_choose "none", -- Delete the conflict region
          },
          diff1 = { --[[ Mappings in single window diff layouts ]]
          },
          diff2 = { --[[ Mappings in 2-way diff layouts ]]
          },
          diff3 = {
            -- Mappings in 3-way diff layouts
            { { "n", "x" }, "2do", actions.diffget "ours" }, -- Obtain the diff hunk from the OURS version of the file
            { { "n", "x" }, "3do", actions.diffget "theirs" }, -- Obtain the diff hunk from the THEIRS version of the file
          },
          diff4 = {
            -- Mappings in 4-way diff layouts
            { { "n", "x" }, "1do", actions.diffget "base" }, -- Obtain the diff hunk from the BASE version of the file
            { { "n", "x" }, "2do", actions.diffget "ours" }, -- Obtain the diff hunk from the OURS version of the file
            { { "n", "x" }, "3do", actions.diffget "theirs" }, -- Obtain the diff hunk from the THEIRS version of the file
          },
          file_panel = {
            ["j"] = actions.next_entry, -- Bring the cursor to the next file entry
            ["<down>"] = actions.next_entry,
            ["k"] = actions.prev_entry, -- Bring the cursor to the previous file entry.
            ["<up>"] = actions.prev_entry,
            ["<cr>"] = actions.select_entry, -- Open the diff for the selected entry.
            ["o"] = actions.select_entry,
            ["<2-LeftMouse>"] = actions.select_entry,
            ["-"] = actions.toggle_stage_entry, -- Stage / unstage the selected entry.
            ["S"] = actions.stage_all, -- Stage all entries.
            ["U"] = actions.unstage_all, -- Unstage all entries.
            ["X"] = actions.restore_entry, -- Restore entry to the state on the left side.
            ["R"] = actions.refresh_files, -- Update stats and entries in the file list.
            ["L"] = actions.open_commit_log, -- Open the commit log panel.
            ["<c-b>"] = actions.scroll_view(-0.25), -- Scroll the view up
            ["<c-f>"] = actions.scroll_view(0.25), -- Scroll the view down
            ["<tab>"] = actions.select_next_entry,
            ["<s-tab>"] = actions.select_prev_entry,
            ["gf"] = actions.goto_file,
            ["<C-w><C-f>"] = actions.goto_file_split,
            ["<C-w>gf"] = actions.goto_file_tab,
            ["i"] = actions.listing_style, -- Toggle between 'list' and 'tree' views
            ["fd"] = actions.toggle_flatten_dirs, -- Flatten empty subdirectories in tree listing style.
            ["f"] = actions.focus_files,
            ["F"] = actions.toggle_files,
            ["g<C-x>"] = actions.cycle_layout,
            ["[x"] = actions.prev_conflict,
            ["]x"] = actions.next_conflict,
          },
          file_history_panel = {
            ["g!"] = actions.options, -- Open the option panel
            ["<C-A-d>"] = actions.open_in_diffview, -- Open the entry under the cursor in a diffview
            ["y"] = actions.copy_hash, -- Copy the commit hash of the entry under the cursor
            ["L"] = actions.open_commit_log,
            ["zR"] = actions.open_all_folds,
            ["zM"] = actions.close_all_folds,
            ["j"] = actions.next_entry,
            ["<down>"] = actions.next_entry,
            ["k"] = actions.prev_entry,
            ["<up>"] = actions.prev_entry,
            ["<cr>"] = actions.select_entry,
            ["o"] = actions.select_entry,
            ["<2-LeftMouse>"] = actions.select_entry,
            ["<c-b>"] = actions.scroll_view(-0.25),
            ["<c-f>"] = actions.scroll_view(0.25),
            ["<tab>"] = actions.select_next_entry,
            ["<s-tab>"] = actions.select_prev_entry,
            ["gf"] = actions.goto_file,
            ["<C-w><C-f>"] = actions.goto_file_split,
            ["<C-w>gf"] = actions.goto_file_tab,
            ["f"] = actions.focus_files,
            ["F"] = actions.toggle_files,
            ["g<C-x>"] = actions.cycle_layout,
          },
          option_panel = {
            ["<tab>"] = actions.select_entry,
            ["q"] = actions.close,
          },
        },
      }
    end,
    on_setup = function(config)
      require("diffview").setup(config.setup)
    end,
    wk = {
      ["g"] = {
        ["a"] = { ":DiffviewFileHistory %<CR>", "buffer commits" },
        ["A"] = { ":DiffviewFileHistory<CR>", "workspace commits" },
        ["d"] = { ":DiffviewOpen<CR>", "diff view open" },
        ["D"] = { ":DiffviewClose<CR>", "diff view close" },
        ["v"] = { ":DiffviewFileHistory<CR>", "workspace commits" },
        ["C"] = { ":DiffviewOpen ", "open and compare with version" },
      },
    },
  })
end

return M
