local M = {}

local extension_name = "neotree_nvim"

function M.config()
  lvim.extensions[extension_name] = {
    active = true,
    on_config_done = nil,
    setup = {
      close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded",
      enable_git_status = false,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 0, -- extra padding on left hand side
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        git_status = {
          highlight = "NeoTreeDimText", -- if you remove this the status will be colorful
        },
      },
      filesystem = {
        filters = { --These filters are applied to both browsing and searching
          show_hidden = true,
          respect_gitignore = true,
        },
        follow_current_file = false, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        use_libuv_file_watcher = true, -- This will use the OS level file watchers
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
            ["H"] = "toggle_hidden",
            ["I"] = "toggle_gitignore",
            ["R"] = "refresh",
            ["/"] = "fuzzy_finder",
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
