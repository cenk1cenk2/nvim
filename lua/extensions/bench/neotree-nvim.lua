local M = {}

local extension_name = "neotree_nvim"
-- {
--   "nvim-neo-tree/neo-tree.nvim",
--   config = function()
--     require("extensions.neotree-nvim").setup()
--   end,
--   branch = "v2.x",
--   disable = not lvim.extensions.neotree_nvim.active,
--   requires = {
--     "nvim-lua/plenary.nvim",
--     "kyazdani42/nvim-web-devicons",
--     "MunifTanjim/nui.nvim",
--   },
-- },

function M.config()
  lvim.extensions[extension_name] = {
    active = false,
    on_config_done = nil,
    setup = {
      close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 0, -- extra padding on left hand side
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        git_status = {
          symbols = {
            -- Change type
            added = "✚",
            deleted = "✖",
            modified = "",
            renamed = "",
            -- Status type
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
          },
        },
      },
      filesystem = {
        filtered_items = {
          visible = true, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            --"node_modules"
          },
          never_show = { -- remains hidden even if visible is toggled to true
            --".DS_Store",
            --"thumbs.db"
          },
        },
        follow_current_file = false, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        use_libuv_file_watcher = false, -- This will use the OS level file watchers
        -- to detect changes instead of relying on nvim autocmd events.
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_split",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        window = {
          position = "left",
          width = 40,
          mappings = {
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["l"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["h"] = "close_node",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["I"] = "toggle_hidden",
            ["R"] = "refresh",
            ["g"] = "fuzzy_finder",
            --["/"] = "filter_as_you_type", -- this was the default until v1.28
            --["/"] = "none" -- Assigning a key to "none" will remove the default mapping
            ["f"] = "filter_on_submit",
            ["F"] = "clear_filter",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["m"] = "move", -- takes text input for destination
            ["q"] = "close_window",
            ["<space>"] = "none",
          },
        },
      },
      buffers = {
        show_unloaded = true,
        window = {
          position = "right",
          mappings = {
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["R"] = "refresh",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["bd"] = "buffer_delete",
            ["q"] = "close_window",
            ["<space>"] = "none",
          },
        },
      },
      git_status = {
        window = {
          position = "float",
          mappings = {
            ["<2-LeftMouse>"] = "open",
            ["<cr>"] = "open",
            ["l"] = "open",
            ["S"] = "open_split",
            ["s"] = "open_vsplit",
            ["h"] = "close_node",
            ["R"] = "refresh",
            ["d"] = "delete",
            ["r"] = "rename",
            ["c"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
            ["q"] = "close_window",
            ["<space>"] = "none",
          },
        },
      },
    },
  }
end

function M.setup()
  local extension = require "neo-tree"

  extension.setup(lvim.extensions[extension_name].setup)

  vim.cmd [[
    hi link NeoTreeDirectoryName Directory
    hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
  ]]

  lvim.builtin.which_key.mappings["e"] = { ":NeoTreeFocusToggle<CR>", "tree" }
  lvim.builtin.which_key.mappings[","] = { ":NeoTreeReveal<CR>", "find file in explorer" }
  lvim.builtin.which_key.mappings["."] = { ":NeoTreeFloat buffers<CR>", "open buffers in tree" }
  lvim.builtin.which_key.mappings["-"] = { ":NeoTreeFloat git_status<CR>", "git files in tree" }

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
