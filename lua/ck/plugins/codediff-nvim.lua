-- https://github.com/esmuellert/codediff.nvim
local M = {}

local log = require("ck.log")

M.name = "esmuellert/codediff.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "esmuellert/codediff.nvim",
        dir = "~/development/codediff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = { "CodeDiff" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "codediff-explorer",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.left, {
          {
            ft = "codediff-explorer",
            title = "CodeDiff",
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
            if is_loaded("codediff") then
              vim.cmd("tabclose")
            end
          end)

          return before_save(name)
        end

        return c
      end)
    end,
    setup = function()
      return {
        highlights = {
          line_insert = "DiffAdd",
          line_delete = "DiffDelete",
          char_insert = nil,
          char_delete = nil,
          char_brightness = nil,
          conflict_sign = nil,
          conflict_sign_resolved = nil,
          conflict_sign_accepted = nil,
          conflict_sign_rejected = nil,
        },
        diff = {
          disable_inlay_hints = true,
          max_computation_time_ms = 5000,
          hide_merge_artifacts = false,
          original_position = "left",
          conflict_ours_position = "right",
          conflict_result_position = "center",
        },
        explorer = {
          position = "left",
          width = 50,
          height = 15,
          indent_markers = true,
          icons = {
            folder_closed = "",
            folder_open = "",
          },
          view_mode = "list",
          file_filter = {
            ignore = {},
          },
        },
        keymaps = {
          view = {
            quit = "q",
            toggle_explorer = "<localleader>e",
            next_hunk = "]c",
            prev_hunk = "[c",
            next_file = "<C-n>",
            prev_file = "<C-p>",
            diff_get = "do",
            diff_put = "dp",
          },
          explorer = {
            select = "<CR>",
            hover = "K",
            refresh = "R",
            toggle_view_mode = "i",
            toggle_stage = "s",
            stage_all = "S",
            unstage_all = "U",
            restore = "X",
          },
          conflict = {
            accept_incoming = "<localleader>ct",
            accept_current = "<localleader>co",
            accept_both = "<localleader>cb",
            discard = "<localleader>cx",
            next_conflict = "]x",
            prev_conflict = "[x",
            diffget_incoming = "2do",
            diffget_current = "3do",
          },
        },
      }
    end,
    on_setup = function(c)
      require("codediff").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.GIT, "a" }),
          function()
            vim.cmd([[CodeDiff history %]])
          end,
          desc = "buffer commits",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "A" }),
          function()
            vim.cmd([[CodeDiff history % --base WORKING]])
          end,
          desc = "buffer commits [HEAD]",
          mode = { "n", "v" },
        },
        {
          fn.wk_keystroke({ categories.GIT, "d" }),
          function()
            vim.cmd([[CodeDiff]])
          end,
          desc = "diff view toggle",
        },
        {
          fn.wk_keystroke({ categories.GIT, "D" }),
          function()
            vim.cmd([[CodeDiff HEAD]])
          end,
          desc = "diff with head",
        },
        {
          fn.wk_keystroke({ categories.GIT, "w" }),
          function()
            vim.cmd([[CodeDiff history]])
          end,
          desc = "workspace commits",
        },
        {
          fn.wk_keystroke({ categories.GIT, "W" }),
          function()
            vim.cmd([[CodeDiff history --base WORKING]])
          end,
          desc = "workspace commits [HEAD]",
        },
        {
          fn.wk_keystroke({ categories.GIT, "c" }),
          function()
            M.compare_with_branch()
          end,
          desc = "compare with branch",
        },
        {
          fn.wk_keystroke({ categories.GIT, "C" }),
          function()
            M.compare_buffer_with_branch()
          end,
          desc = "compare buffer with branch",
        },
        {
          fn.wk_keystroke({ categories.GIT, "f" }),
          function()
            M.compare_files()
          end,
          desc = "compare files",
        },
        {
          fn.wk_keystroke({ categories.GIT, "F" }),
          function()
            M.compare_directories()
          end,
          desc = "compare directories",
        },
      }
    end,
  })
end

function M.compare_with_branch()
  local store_key = "CODEDIFF_COMPARE_BRANCH"
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

    vim.cmd(":CodeDiff " .. branch .. "...")
  end)
end

function M.compare_buffer_with_branch()
  local store_key = "CODEDIFF_COMPARE_BRANCH"
  local shada = require("ck.modules.shada")
  local stored_value = shada.get(store_key)

  vim.ui.input({
    prompt = "Compare buffer with branch:",
    default = stored_value,
  }, function(branch)
    if branch == nil then
      log:warn("Nothing to compare.")

      return
    end

    log:info("Comparing buffer with branch: %s -> %s", require("ck.utils.fs").get_project_buffer_filepath(), branch)
    shada.set(store_key, branch)

    vim.cmd(":CodeDiff file " .. branch .. "...")
  end)
end

function M.compare_files()
  vim.ui.input({
    prompt = "First file path:",
  }, function(file_a)
    if file_a == nil or file_a == "" then
      log:warn("No file selected.")

      return
    end

    local expanded_a = vim.fn.expand(file_a)
    if vim.fn.filereadable(expanded_a) == 0 then
      log:error("File not found: %s", expanded_a)

      return
    end

    vim.ui.input({
      prompt = "Second file path:",
    }, function(file_b)
      if file_b == nil or file_b == "" then
        log:warn("No file selected.")

        return
      end

      local expanded_b = vim.fn.expand(file_b)
      if vim.fn.filereadable(expanded_b) == 0 then
        log:error("File not found: %s", expanded_b)

        return
      end

      log:info("Comparing files: %s <-> %s", expanded_a, expanded_b)
      vim.cmd(string.format(":CodeDiff file %s %s", vim.fn.fnameescape(expanded_a), vim.fn.fnameescape(expanded_b)))
    end)
  end)
end

function M.compare_directories()
  vim.ui.input({
    prompt = "First directory path:",
  }, function(dir1)
    if dir1 == nil or dir1 == "" then
      log:warn("No directory selected.")

      return
    end

    local expanded_dir1 = vim.fn.expand(dir1)
    if vim.fn.isdirectory(expanded_dir1) == 0 then
      log:error("Directory not found: %s", expanded_dir1)

      return
    end

    vim.ui.input({
      prompt = "Second directory path:",
    }, function(dir2)
      if dir2 == nil or dir2 == "" then
        log:warn("No directory selected.")

        return
      end

      local expanded_dir2 = vim.fn.expand(dir2)
      if vim.fn.isdirectory(expanded_dir2) == 0 then
        log:error("Directory not found: %s", expanded_dir2)

        return
      end

      log:info("Comparing directories: %s <-> %s", expanded_dir1, expanded_dir2)
      vim.cmd(string.format(":CodeDiff dir %s %s", vim.fn.fnameescape(expanded_dir1), vim.fn.fnameescape(expanded_dir2)))
    end)
  end)
end

return M
