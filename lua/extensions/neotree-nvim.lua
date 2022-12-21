-- https://github.com/nvim-neo-tree/neo-tree.nvim
local M = {}

local extension_name = "neotree_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function(config)
      return {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "kyazdani42/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
          "s1n7ax/nvim-window-picker",
        },
        config = function()
          require("utils.setup").plugin_configure "neotree_nvim"
        end,
        init = function()
          require("utils.setup").plugin_init "neotree_nvim"
        end,
        cmd = { "NeoTreeReveal", "NeoTreeFocusToggle", "NeoTreeFloat" },
        enabled = config.active,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes {
        "neo-tree",
      }
    end,
    setup = function()
      local Log = require "lvim.core.log"
      local system_registry = "+"

      local function get_telescope_options(state, opts)
        return vim.tbl_extend("force", opts, {
          hidden = true,
          attach_mappings = function(prompt_bufnr)
            local actions = require "telescope.actions"

            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local action_state = require "telescope.actions.state"
              local selection = action_state.get_selected_entry()
              local filename = selection.filename
              if filename == nil then
                filename = selection[1]
              end

              -- any way to open the file without triggering auto-close event of neo-tree?
              if opts.cwd then
                filename = join_paths(opts.cwd, filename)
              end

              require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
            end)

            return true
          end,
        })
      end

      local function get_node_dir(state)
        local node = state.tree:get_node()
        local path
        if node.type == "directory" then
          path = node:get_id()
        elseif node.type == "file" then
          path = node:get_parent_id()
        else
          Log:warn "Finding in node only works for files and directories."
          return
        end

        return path
      end

      return {
        source_selector = {
          winbar = true,
          statusline = false,
        },
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = lvim.ui.border,
        enable_git_status = true,
        enable_diagnostics = false,
        sort_case_insensitive = true, -- used when sorting files and directories in the tree
        sort_function = nil, -- use a custom function for sorting files and directories in the tree
        -- sort_function = function (a,b)
        --       if a.type == b.type then
        --           return a.path > b.path
        --       else
        --           return a.type > b.type
        --       end
        --   end , -- this sorts files and directories descendantly
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            padding = 0, -- extra padding on left hand side
            -- indent guides
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
            highlight = "NeoTreeFileIcon",
          },
          modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
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
        window = {
          position = "left",
          width = 50,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ["<space>"] = "none",
            ["<2-LeftMouse>"] = "open_with_window_picker",
            ["<cr>"] = "open_with_window_picker",
            ["l"] = "open_with_window_picker",
            ["<esc>"] = "revert_preview",
            ["P"] = { "toggle_preview", config = { use_float = true } },
            ["v"] = "open_split",
            ["V"] = "open_vsplit",
            -- ["S"] = "split_with_window_picker",
            -- ["s"] = "vsplit_with_window_picker",
            ["t"] = "open_tabnew",
            -- ["<cr>"] = "open_drop",
            -- ["t"] = "open_tab_drop",
            ["w"] = "open_with_window_picker",
            ["h"] = "close_node",
            ["z"] = "close_all_nodes",
            ["Z"] = "expand_all_nodes",
            ["a"] = {
              "add",
              -- some commands may take optional config options, see `:h neo-tree-mappings` for details
              config = {
                show_path = "none", -- "none", "relative", "absolute"
              },
            },
            ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
            ["d"] = "delete",
            ["r"] = "rename",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
            ["Y"] = "copy_filename",
            ["C"] = "copy_filepath",
            ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
            ["H"] = "prev_source",
            ["L"] = "next_source",
          },
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_hidden = true, -- only works on Windows for hidden files/directories
            hide_by_name = {
              --"node_modules"
            },
            hide_by_pattern = { -- uses glob style patterns
              --"*.meta",
              --"*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
              --".gitignored",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
              ".DS_Store",
              "thumbs.db",
              ".git",
            },
            never_show_by_pattern = { -- uses glob style patterns
              --".null-ls_*",
            },
          },
          follow_current_file = false, -- This will find and focus the file in the active buffer every
          -- time the current file is changed while the tree is open.
          group_empty_dirs = false, -- when true, empty folders will be grouped together
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
              ["I"] = "toggle_hidden",
              ["/"] = "fuzzy_finder",
              ["D"] = "fuzzy_finder_directory",
              ["f"] = "filter_on_submit",
              ["F"] = "clear_filter",
              ["[n"] = "prev_git_modified",
              ["]n"] = "next_git_modified",
              ["s"] = "system_open",
              ["S"] = "run_command",
              ["gp"] = "telescope_find",
              ["gt"] = "telescope_grep",
            },
          },
          commands = {
            system_open = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              -- macOs: open file in default application in the background.
              -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
              -- vim.api.nvim_command("silent !open -g " .. path)
              -- Linux: open file in default application

              vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
            end,
            copy_filename = function(state)
              local node = state.tree:get_node()

              vim.fn.setreg(system_registry, node.name, "c")
            end,
            copy_filepath = function(state)
              local node = state.tree:get_node()
              local full_path = node.path
              local relative_path = full_path:sub(#state.path + 2)

              vim.fn.setreg(system_registry, relative_path, "c")
            end,
            run_command = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.api.nvim_input(":! " .. path .. "<Home>")
            end,
            telescope_find = function(state)
              local path = get_node_dir(state)

              require("telescope.builtin").find_files(get_telescope_options(state, {
                cwd = path,
              }))
            end,
            telescope_grep = function(state)
              local path = get_node_dir(state)

              require("telescope.builtin").live_grep(get_telescope_options(state, {
                -- cwd = path,
                search_dirs = { path },
              }))
            end,
          },
        },
        buffers = {
          follow_current_file = true, -- This will find and focus the file in the active buffer every
          -- time the current file is changed while the tree is open.
          group_empty_dirs = true, -- when true, empty folders will be grouped together
          show_unloaded = true,
          window = {
            mappings = {
              ["d"] = "buffer_delete",
              ["D"] = "buffer_delete",
              ["<bs>"] = "navigate_up",
              ["."] = "set_root",
            },
          },
        },
        git_status = {
          window = {
            position = "float",
            mappings = {
              ["A"] = "git_add_all",
              ["d"] = "git_unstage_file",
              ["a"] = "git_add_file",
              ["RR"] = "git_revert_file",
              ["C"] = "git_commit",
              ["P"] = "git_push",
              ["gg"] = "git_commit_and_push",
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("neo-tree").setup(config.setup)
    end,
    wk = {

      ["e"] = { ":NeoTreeFocusToggle<CR>", "tree" },
      [","] = { ":NeoTreeReveal<CR>", "find file in explorer" },
      ["."] = { ":NeoTreeFloat buffers<CR>", "open buffers in tree" },
      ["-"] = { ":NeoTreeFloat git_status<CR>", "git files in tree" },
    },
  })
end

return M
