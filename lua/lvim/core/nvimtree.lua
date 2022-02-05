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
      ignore_ft_on_setup = {
        "startify",
        "dashboard",
        "alpha",
      },
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
      git = {
        enable = true,
        ignore = true,
        timeout = 200,
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
        signcolumn = "yes",
      },
      window_picker_exclude = {
        filetype = { "notify", "spectre_panel", "Outline", "packer", "qf", "lsp_floating_window" },
        buftype = { "terminal" },
      },
      filters = {
        dotfiles = false,
        custom = { "node_modules", ".cache" },
      },
      trash = {
        cmd = "trash",
        require_confirm = true,
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
          staged = "✓",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "★",
          ignored = "◌",
        },
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
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

  -- Add useful keymaps
  if not lvim.builtin.nvimtree.setup.view.mappings.list or #lvim.builtin.nvimtree.setup.view.mappings.list == 0 then
    lvim.builtin.nvimtree.setup.view.mappings.list = {
      -- mappings
      { key = "<CR>", action = "edit" },
      { key = "l", action = "edit" },
      { key = "o", action = "edit" },
      { key = "<2-LeftMouse>", action = "edit" },
      { key = "<2-RightMouse>", action = "cd" },
      { key = "w", action = "cd" },
      { key = "v", action = "vsplit" },
      { key = "V", action = "split" },
      { key = "<C-t>", action = "tabnew" },
      { key = "h", action = "close_node" },
      { key = "<BS>", action = "close_node" },
      { key = "<S-CR>", action = "close_node" },
      { key = "<Tab>", action = "preview" },
      { key = "I", action = "toggle_ignored" },
      { key = "H", action = "toggle_dotfiles" },
      { key = "R", action = "refresh" },
      { key = "a", action = "create" },
      { key = "d", action = "remove" },
      { key = "r", action = "rename" },
      { key = "<C-r>", action = "full_rename" },
      { key = "x", action = "cut" },
      { key = "c", action = "copy" },
      { key = "p", action = "paste" },
      { key = "[c", action = "prev_git_item" },
      { key = "]c", action = "next_git_item" },
      { key = "-", action = "dir_up" },
      { key = "q", action = "close" },
      { key = "gtf", cb = "<cmd>lua require'lvim.core.nvimtree'.start_telescope('find_files')<cr>" },
      { key = "gtg", cb = "<cmd>lua require'lvim.core.nvimtree'.start_telescope('live_grep')<cr>" },
    }
  end

  lvim.builtin.which_key.mappings["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" }
  lvim.builtin.which_key.mappings[","] = { ":NvimTreeFindFile<CR>", "find file in explorer" }
  lvim.builtin.which_key.mappings["."] = { ":NvimTreeFindFile<CR>", "find file in explorer" }

  -- local tree_view = require "nvim-tree.view"
  --
  -- -- Add nvim_tree open callback
  -- local open = tree_view.open
  -- tree_view.open = function()
  --   M.on_open()
  --   open()
  --
  --   local function on_open()
  --     -- if package.loaded["bufferline.state"] and lvim.builtin.nvimtree.setup.view.side == "left" then
  --     -- require("bufferline.state").set_offset(lvim.builtin.nvimtree.setup.view.width + 1, "")
  --     -- end
  --   end
  --
  --   local function on_close()
  --     -- local bufnr = vim.api.nvim_get_current_buf()
  --     -- local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  --     -- if ft == "NvimTree" and package.loaded["bufferline.state"] then
  --     -- require("bufferline.state").set_offset(0)
  --     -- end
  --   end
  --
  --   local tree_view = require "nvim-tree.view"
  --   local default_open = tree_view.open
  --   local default_close = tree_view.close
  --
  --   tree_view.open = function()
  --     on_open()
  --     default_open()
  --   end
  --
  --   tree_view.close = function()
  --     on_close()
  --     default_close()
  --   end
  -- end

  require("nvim-tree").setup(lvim.builtin.nvimtree.setup)

  if lvim.builtin.nvimtree.on_config_done then
    lvim.builtin.nvimtree.on_config_done(nvim_tree_config)
  end
end

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

return M
