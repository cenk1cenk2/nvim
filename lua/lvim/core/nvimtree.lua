local M = {}
local Log = require "lvim.core.log"

function M.config()
  lvim.builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    setup = {
      -- disables netrw completely
      disable_netrw = true,
      -- hijack netrw window on startup
      hijack_netrw = true,
      -- open the tree when running this setup function
      open_on_setup = false,
      -- will not open on setup if the filetype is in this list
      ignore_ft_on_setup = { "dashboard" },
      -- closes neovim automatically when the tree is the last **WINDOW** in the view
      auto_close = false,
      -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
      open_on_tab = true,
      -- hijack the cursor in the tree to put it at the start of the filename
      hijack_cursor = false,
      -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
      update_cwd = false,
      update_to_buf_dir = {
        enable = true,
        auto_open = true,
      },
      -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
      update_focused_file = {
        -- enables the feature
        enable = false,
        -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
        -- only relevant when `update_focused_file.enable` is true
        update_cwd = false,
        -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
        -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
        ignore_list = {},
      },
      -- configuration options for the system open command (`s` in the tree by default)
      system_open = {
        -- the command to run this, leaving nil should work in most cases
        cmd = nil,
        -- the command arguments as a list
        args = {},
      },
      diagnostics = { enable = true, icons = { hint = "", info = "", warning = "", error = "" } },
      filters = {
        dotfiles = false,
        custom = { ".git" },
      },
      git = {
        enable = true,
        ignore = true,
        timeout = 500,
      },
      view = {
        -- width of the window, can be either a number (columns) or a string in `%`
        width = 40,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = "left",
        -- if true the tree will resize itself after opening a file
        auto_resize = true,
        number = false,
        relativenumber = false,
        mappings = {
          -- custom only false will merge the list with the default mappings
          -- if true, it will only use your list to set the mappings
          custom_only = false,
          -- list of mappings to set on the tree manually
        },
      },
      indent_markers = 1,
      special_files = { ["package.json"] = 1, ["README.md"] = 1, ["node_modules"] = 1 },
      show_icons = { git = 1, folders = 1, files = 1, folder_arrows = 1, tree_width = 40 },
      quit_on_open = 0,
      git_hl = 1,
      disable_window_picker = 0,
      root_folder_modifier = ":t",
      allow_resize = 1,
      auto_ignore_ft = { "startify", "dashboard" },
      icons = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "U",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  }
  lvim.builtin.which_key.mappings["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
end

function M.setup()
  local status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
  if not status_ok then
    Log:error "Failed to load nvim-tree.config"
    return
  end

  local table_utils = require "lvim.utils.table"
  for opt, val in pairs(lvim.builtin.nvimtree.setup) do
    if
      not table_utils.contains({
        "disable_netrw",
        "hijack_netrw",
        "open_on_setup",
        "ignore_ft_on_setup",
        "auto_close",
        "open_on_tab",
        "hijack_cursor",
        "update_cwd",
        "update_to_buf_dir",
        "diagnostics",
        "update_focused_file",
        "system_open",
        "filters",
        "git",
        "view",
        "trash",
      }, function(entry)
        return opt == entry
      end)
    then
      vim.g["nvim_tree_" .. opt] = val
    end
  end

  -- Implicitly update nvim-tree when project module is active
  if lvim.builtin.project.active then
    lvim.builtin.nvimtree.respect_buf_cwd = 0 -- this was 1 before, so if anything goes wrong lets switch it back
    lvim.builtin.nvimtree.setup.update_cwd = true
    -- lvim.builtin.nvimtree.setup.disable_netrw = false
    -- lvim.builtin.nvimtree.setup.hijack_netrw = false
    -- vim.g.netrw_banner = false
  end

  local tree_cb = nvim_tree_config.nvim_tree_callback

  if not lvim.builtin.nvimtree.setup.view.mappings.list then
    lvim.builtin.nvimtree.setup.view.mappings.list = {
      -- mappings
      { key = "<CR>", cb = tree_cb "edit" },
      { key = "l", cb = tree_cb "edit" },
      { key = "o", cb = tree_cb "edit" },
      { key = "<2-LeftMouse>", cb = tree_cb "edit" },
      { key = "<2-RightMouse>", cb = tree_cb "cd" },
      { key = "w", cb = tree_cb "cd" },
      { key = "v", cb = tree_cb "vsplit" },
      { key = "s", cb = tree_cb "split" },
      { key = "<C-t>", cb = tree_cb "tabnew" },
      { key = "h", cb = tree_cb "close_node" },
      { key = "<BS>", cb = tree_cb "close_node" },
      { key = "<S-CR>", cb = tree_cb "close_node" },
      { key = "<Tab>", cb = tree_cb "preview" },
      { key = "I", cb = tree_cb "toggle_ignored" },
      { key = "H", cb = tree_cb "toggle_dotfiles" },
      { key = "R", cb = tree_cb "refresh" },
      { key = "a", cb = tree_cb "create" },
      { key = "d", cb = tree_cb "remove" },
      { key = "r", cb = tree_cb "rename" },
      { key = "<C-r>", cb = tree_cb "full_rename" },
      { key = "x", cb = tree_cb "cut" },
      { key = "c", cb = tree_cb "copy" },
      { key = "p", cb = tree_cb "paste" },
      { key = "[c", cb = tree_cb "prev_git_item" },
      { key = "]c", cb = tree_cb "next_git_item" },
      { key = "-", cb = tree_cb "dir_up" },
      { key = "q", cb = tree_cb "close" },
    }
  end

  lvim.builtin.which_key.mappings["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
  lvim.builtin.which_key.mappings["."] = { ":NvimTreeFindFile<CR>", "find file in explorer" }

  local tree_view = require "nvim-tree.view"

  -- Add nvim_tree open callback
  local open = tree_view.open
  tree_view.open = function()
    M.on_open()
    open()
  end

  vim.cmd "au WinClosed * lua require('lvim.core.nvimtree').on_close()"

  require("nvim-tree").setup(lvim.builtin.nvimtree.setup)

  if lvim.builtin.nvimtree.on_config_done then
    lvim.builtin.nvimtree.on_config_done(nvim_tree_config)
  end
end

function M.on_open()
  -- if package.loaded['bufferline.state'] and lvim.builtin.nvimtree.setup.view.side == 'left' then
  --   require('bufferline.state').set_offset(lvim.builtin.nvimtree.setup.view.width + 1, '')
  -- end
end

function M.on_close()
  -- local buf = tonumber(vim.fn.expand '<abuf>')
  -- local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
  -- if ft == 'NvimTree' and package.loaded['bufferline.state'] then require('bufferline.state').set_offset(0) end
end

function M.change_tree_dir(dir)
  local lib_status_ok, lib = pcall(require, "nvim-tree.lib")
  if lib_status_ok then
    lib.change_dir(dir)
  end
end

return M
