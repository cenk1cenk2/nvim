-- https://github.com/sindrets/diffview.nvim
local M = {}

local log = require("ck.log")

M.name = "sindrets/diffview.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewFileHistory", "DiffviewOpen", "DiffviewClose" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "DiffviewFiles",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.left, {
          {
            ft = "DiffviewFiles",
            title = "Diffview",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return 0.25
                end

                return 50
              end,
            },
          },
        })

        return c
      end)

      fn.setup_callback(require("ck.plugins.possession-nvim").name, function(c)
        local before_save = c.hooks.before_save
        c.hooks.before_save = function(name)
          pcall(function()
            if is_loaded("diffview") and next(require("diffview.lib").views) ~= nil then
              vim.cmd("DiffviewClose")
            end
          end)

          return before_save(name)
        end

        return c
      end)
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
            { "n", "g?", actions.help, { desc = "help" } },
            -- The `view` bindings are active in the diff buffers, only when the current
            -- tabpage is a Diffview.
            { "n", "<tab>", actions.select_next_entry, { desc = "open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "open the diff for the previous file" } },
            { "n", "gf", actions.goto_file, { desc = "goto file" } },
            { "n", "<localleader>o", actions.goto_file_edit, { desc = "open file" } },
            { "n", "<localleader>v", actions.goto_file_split, { desc = "goto file in split" } },
            { "n", "<localleader>n", actions.goto_file_tab, { desc = "goto file in tab" } },
            { "n", "<localleader>e", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "<localleader>E", actions.focus_files, { desc = "bring focus to the file panel" } },
            { "n", "<localleader>w", actions.cycle_layout, { desc = "cycle through available layouts." } },
            { "n", "<localleader>co", actions.conflict_choose("ours"), { desc = "choose the ours version of a conflict" } },
            { "n", "<localleader>ao", actions.conflict_choose_all("ours"), { desc = "[all] choose the ours version of a conflict" } },
            { "n", "<localleader>ct", actions.conflict_choose("theirs"), { desc = "choose the theirs version of a conflict" } },
            { "n", "<localleader>at", actions.conflict_choose_all("theirs"), { desc = "[all] choose the theirs version of a conflict" } },
            { "n", "<localleader>cB", actions.conflict_choose("base"), { desc = "choose the base version of a conflict" } },
            { "n", "<localleader>aB", actions.conflict_choose_all("base"), { desc = "[all] choose the base version of a conflict" } },
            { "n", "<localleader>cb", actions.conflict_choose("all"), { desc = "choose all the versions of a conflict" } },
            { "n", "<localleader>ab", actions.conflict_choose_all("all"), { desc = "[all] choose all the versions of a conflict" } },
            { "n", "<localleader>cn", actions.conflict_choose("none"), { desc = "delete the conflict region" } },
            { "n", "<localleader>an", actions.conflict_choose_all("none"), { desc = "[all] delete the conflict region" } },
            { "n", "[x", actions.prev_conflict, { desc = "in the merge_tool: jump to the previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "in the merge_tool: jump to the next conflict" } },
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
            { "n", "g?", actions.help, { desc = "help" } },
            { "n", "<localleader>e", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "<localleader>E", actions.focus_files, { desc = "bring focus to the file panel" } },
            { "n", "<localleader>w", actions.cycle_layout, { desc = "cycle through available layouts." } },
            { "n", "gf", actions.goto_file, { desc = "goto file" } },
            { "n", "<localleader>o", actions.goto_file_edit, { desc = "open file" } },
            { "n", "<localleader>v", actions.goto_file_split, { desc = "goto file in split" } },
            { "n", "<localleader>n", actions.goto_file_tab, { desc = "goto file in tab" } },
            { "n", "j", actions.next_entry, { desc = "bring the cursor to the next file entry" } },
            { "n", "<down>", actions.next_entry, { desc = "bring the cursor to the next file entry." } },
            { "n", "k", actions.prev_entry, { desc = "bring the cursor to the previous file entry." } },
            { "n", "<up>", actions.prev_entry, { desc = "bring the cursor to the previous file entry." } },
            { "n", "l", actions.select_entry, { desc = "open the diff for the selected entry." } },
            { "n", "<cr>", actions.select_entry, { desc = "open the diff for the selected entry." } },
            { "n", "o", actions.select_entry, { desc = "select entry" } },
            { "n", "<2-LeftMouse>", actions.select_entry, { desc = "select entry" } },
            { "n", "s", actions.toggle_stage_entry, { desc = "stage / unstage the selected entry." } },
            { "n", "S", actions.stage_all, { desc = "stage all entries." } },
            { "n", "U", actions.unstage_all, { desc = "unstage all entries." } },
            { "n", "X", actions.restore_entry, { desc = "restore entry to the state on the left side." } },
            { "n", "L", actions.open_commit_log, { desc = "open the commit log panel." } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "scroll the view down" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "next entry" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "previous entry" } },
            { "n", "i", actions.listing_style, { desc = "toggle between 'list' and 'tree' views" } },
            { "n", "f", actions.toggle_flatten_dirs, { desc = "flatten empty subdirectories in tree listing style." } },
            { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list." } },
            { "n", "[x", actions.prev_conflict, { desc = "previous conflict" } },
            { "n", "]x", actions.next_conflict, { desc = "next conflict" } },
          },
          file_history_panel = {
            { "n", "g?", actions.help, { desc = "help" } },
            { "n", "<localleader>e", actions.toggle_files, { desc = "toggle the file panel." } },
            { "n", "<localleader>E", actions.focus_files, { desc = "bring focus to the file panel" } },
            { "n", "gf", actions.goto_file, { desc = "goto file" } },
            { "n", "<localleader>o", actions.goto_file_edit, { desc = "open file" } },
            { "n", "<localleader>v", actions.goto_file_split, { desc = "goto file in split" } },
            { "n", "<localleader>n", actions.goto_file_tab, { desc = "goto file in tab" } },
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
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry, { desc = "select entry" } },
            { "n", "q", actions.close, { desc = "close" } },
          },
        },
      }
    end,
    on_setup = function(c)
      require("diffview").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "a" }),
          function()
            vim.cmd([[DiffviewFileHistory %]])
          end,
          desc = "buffer commits",
          mode = { "n", "v" },
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
  local shada = require("ck.modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Compare with branch:",
    default = stored_value,
  }, function(branch)
    if branch == nil then
      log:warn("Nothing to compare.")

      return
    end

    log:info("Comparing with branch: %s", branch)
    shada.set(store_key, branch)

    vim.cmd(":DiffviewOpen " .. branch)
  end)
end

return M
