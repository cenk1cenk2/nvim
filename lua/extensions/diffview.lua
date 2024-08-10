-- https://github.com/sindrets/diffview.nvim
local M = {}

local Log = require("lvim.core.log")

M.name = "sindrets/diffview.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewFileHistory", "DiffviewOpen", "DiffviewClose" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "DiffviewFiles",
      })
    end,
    setup = function()
      local actions = require("diffview.actions")

      return {
        diff_binaries = false, -- Show diffs for binaries
        use_icons = true, -- Requires nvim-web-devicons
        file_panel = { win_config = { width = 50 } },
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
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          view = {
            -- The `view` bindings are active in the diff buffers, only when the current
            -- tabpage is a Diffview.
            { "n", "<tab>", actions.select_next_entry, { desc = "open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "open the diff for the previous file" } },
            { "n", "gf", actions.goto_file, { desc = "open the file in a new split in the previous tabpage" } },
            { "n", "<leader>E", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "open the file in a new split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "open the file in a new tabpage" } },
            { "n", "ce", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "CE", actions.focus_files, { desc = "bring focus to the file panel" } },
            { "n", "cv", actions.cycle_layout, { desc = "cycle through available layouts." } },
            { "n", "[n", actions.prev_conflict, { desc = "in the merge_tool: jump to the previous conflict" } },
            { "n", "]n", actions.next_conflict, { desc = "in the merge_tool: jump to the next conflict" } },
            { "n", "co", actions.conflict_choose("ours"), { desc = "choose the ours version of a conflict" } },
            { "n", "ct", actions.conflict_choose("theirs"), { desc = "choose the theirs version of a conflict" } },
            { "n", "cB", actions.conflict_choose("base"), { desc = "choose the base version of a conflict" } },
            { "n", "cb", actions.conflict_choose("all"), { desc = "choose all the versions of a conflict" } },
            { "n", "cn", actions.conflict_choose("none"), { desc = "delete the conflict region" } },
          },
          diff1 = { --[[ Mappings in single window diff layouts ]]
          },
          diff2 = { --[[ Mappings in 2-way diff layouts ]]
          },
          diff3 = {
            -- Mappings in 3-way diff layouts
            { { "n", "x" }, "2do", actions.diffget("ours") }, -- Obtain the diff hunk from the OURS version of the file
            { { "n", "x" }, "3do", actions.diffget("theirs") }, -- Obtain the diff hunk from the THEIRS version of the file
          },
          diff4 = {
            -- Mappings in 4-way diff layouts
            { { "n", "x" }, "1do", actions.diffget("base") }, -- Obtain the diff hunk from the BASE version of the file
            { { "n", "x" }, "2do", actions.diffget("ours") }, -- Obtain the diff hunk from the OURS version of the file
            { { "n", "x" }, "3do", actions.diffget("theirs") }, -- Obtain the diff hunk from the THEIRS version of the file
          },
          file_panel = {
            { "n", "j", actions.next_entry, { desc = "bring the cursor to the next file entry" } },
            { "n", "<down>", actions.next_entry, { desc = "bring the cursor to the next file entry." } },
            { "n", "k", actions.prev_entry, { desc = "bring the cursor to the previous file entry." } },
            { "n", "<up>", actions.prev_entry, { desc = "bring the cursor to the previous file entry." } },
            { "n", "l", actions.select_entry, { desc = "open the diff for the selected entry." } },
            { "n", "<cr>", actions.select_entry, { desc = "open the diff for the selected entry." } },
            { "n", "o", actions.select_entry, { desc = "select entry" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "select entry" } },
            { "n", "a", actions.toggle_stage_entry, { desc = "stage / unstage the selected entry." } },
            { "n", "A", actions.stage_all, { desc = "stage all entries." } },
            { "n", "U", actions.unstage_all, { desc = "unstage all entries." } },
            { "n", "X", actions.restore_entry, { desc = "restore entry to the state on the left side." } },
            { "n", "L", actions.open_commit_log, { desc = "open the commit log panel." } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "scroll the view down" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "next entry" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "previous entry" } },
            { "n", "gf", actions.goto_file, { desc = "goto file" } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "goto file in split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "goto file in tab" } },
            { "n", "i", actions.listing_style, { desc = "toggle between 'list' and 'tree' views" } },
            { "n", "f", actions.toggle_flatten_dirs, { desc = "flatten empty subdirectories in tree listing style." } },
            { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list." } },
            { "n", "ce", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "CE", actions.focus_files, { desc = "bring focus to the file panel" } },
            { "n", "cv", actions.cycle_layout, { desc = "cycle layout" } },
            { "n", "[x", actions.prev_conflict, { desc = "previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "next conflict" } },
          },
          file_history_panel = {
            { "n", "g!", actions.options, { desc = "open the option panel" } },
            { "n", "<C-A-d>", actions.open_in_diffview, { desc = "open the entry under the cursor in a diffview" } },
            { "n", "y", actions.copy_hash, { desc = "copy the commit hash of the entry under the cursor" } },
            { "n", "L", actions.open_commit_log, { desc = "commit log" } },
            { "n", "zR", actions.open_all_folds, { desc = "open all folds" } },
            { "n", "zM", actions.close_all_folds, { desc = "close all folds" } },
            { "n", "j", actions.next_entry, { desc = "next entry" } },
            { "n", "<down>", actions.next_entry, { desc = "next entry" } },
            { "n", "k", actions.prev_entry, { desc = "previous entry" } },
            { "n", "<up>", actions.prev_entry, { desc = "previous entry" } },
            { "n", "<cr>", actions.select_entry, { desc = "select entry" } },
            { "n", "l", actions.select_entry, { desc = "select entry" } },
            { "n", "o", actions.select_entry, { desc = "select entry" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "select entry" } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "scroll down" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "scroll up" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "next entry" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "previous entry" } },
            { "n", "gf", actions.goto_file, { desc = "goto file" } },
            { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "goto file in split" } },
            { "n", "<C-w>gf", actions.goto_file_tab, { desc = "goto file in tab" } },
            { "n", "e", actions.focus_files, { desc = "focus file" } },
            { "n", "E", actions.toggle_files, { desc = "toggle files" } },
            { "n", "cv", actions.cycle_layout, { desc = "cycle layout" } },
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry, { desc = "select entry" } },
            { "n", "q", actions.close, { desc = "close" } },
          },
        },
      }
    end,
    on_setup = function(config)
      require("diffview").setup(config.setup)
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.GIT, "a" }),
          function()
            vim.cmd([[DiffviewFileHistory %]])
          end,
          desc = "buffer commits",
        },
        {
          fn.wk_keystroke({ categories.GIT, "d" }),
          function()
            if next(require("diffview.lib").views) == nil then
              vim.cmd("DiffviewOpen")
            else
              vim.cmd("DiffviewClose")
            end
          end,
          desc = "diff view toggle",
        },
        {
          fn.wk_keystroke({ categories.GIT, "w" }),
          function()
            vim.cmd([[DiffviewFileHistory]])
          end,
          desc = "workspace commits",
        },
        {
          fn.wk_keystroke({ categories.GIT, "c" }),
          function()
            M.compare_with_branch()
          end,
          desc = "compare with branch",
        },
      }
    end,
  })
end

function M.compare_with_branch()
  local store_key = "DIFFVIEW_COMPARE_BRANCH"
  local shada = require("modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Compare with branch:",
    default = stored_value,
  }, function(branch)
    if branch == nil then
      Log:warn("Nothing to compare.")

      return
    end

    Log:info(("Comparing with branch: %s"):format(branch))
    shada.set(store_key, branch)

    vim.cmd(":DiffviewOpen " .. branch)
  end)
end

return M
