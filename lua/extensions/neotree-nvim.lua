-- https://github.com/nvim-neo-tree/neo-tree.nvim
local M = {}

local extension_name = "neotree_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
          "s1n7ax/nvim-window-picker",
        },
        cmd = { "Neotree" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "neo-tree",
        "neo-tree-preview",
        "neo-tree-popup",
      })
    end,
    on_init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    setup = function(_, fn)
      local Log = require("lvim.core.log")
      local system_register = lvim.system_register

      local function get_telescope_options(state, opts)
        return vim.tbl_extend("force", opts, {
          hidden = true,
          attach_mappings = function(prompt_bufnr)
            local actions = require("telescope.actions")

            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local action_state = require("telescope.actions.state")
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
        -- if node.type == "directory" then
        --   path = node:get_id()
        if node.type == "file" or node.type == "directory" then
          path = node:get_parent_id()
        else
          Log:warn("Finding in node only works for files and directories.")
          return
        end

        return path
      end

      local function index_of(array, value)
        for i, v in ipairs(array) do
          if v == value then
            return i
          end
        end
        return nil
      end

      local function get_siblings(state, node)
        local parent = state.tree:get_node(node:get_parent_id())
        local siblings = parent:get_child_ids()

        return siblings
      end

      local renderer = require("neo-tree.ui.renderer")

      local setup = {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        source_selector = {
          winbar = false,
          statusline = false,
          sources = {
            { source = "filesystem", display_name = (" %s Files "):format(lvim.ui.icons.ui.Folder) },
            -- { source = "buffers", display_name = (" %s Buffers "):format(lvim.ui.icons.ui.File) },
            -- { source = "git_status", display_name = (" %s Git "):format(lvim.ui.icons.ui.Git) },
            -- { source = "document_symbols", display_name = (" %s Symbols "):format(lvim.ui.icons.kind.Function) },
          },
        },
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        enable_cursor_hijack = true, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
        popup_border_style = lvim.ui.border,
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/338
        enable_diagnostics = false,
        enable_git_status = true,
        enable_modified_markers = true, -- Show markers for files with unsaved changes.sort_case_insensitive = true, -- used when sorting files and directories in the tree
        enable_opened_markers = true,
        open_files_do_not_replace_types = lvim.disabled_filetypes, -- when opening files, do not use windows containing these filetypes or buftypes
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
            indent_marker = lvim.ui.icons.ui.LineMiddle,
            last_indent_marker = lvim.ui.icons.ui.LineMiddleEnd,
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = lvim.ui.icons.ui.ChevronShortRight,
            expander_expanded = lvim.ui.icons.ui.ChevronShortDown,
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            folder_closed = lvim.ui.icons.ui.Folder,
            folder_open = lvim.ui.icons.ui.FolderOpen,
            folder_empty = lvim.ui.icons.ui.EmptyFolder,
            default = lvim.ui.icons.ui.File,
            highlight = "NeoTreeFileIcon",
          },
          modified = {
            symbol = lvim.ui.icons.git.LineModified,
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
              added = lvim.ui.icons.git.FileAdded,
              deleted = lvim.ui.icons.git.FileDeleted,
              modified = lvim.ui.icons.git.FileModified,
              renamed = lvim.ui.icons.git.FileRenamed,
              -- Status type
              untracked = lvim.ui.icons.git.FileUntracked,
              ignored = lvim.ui.icons.git.FileIgnored,
              unstaged = lvim.ui.icons.git.FileUnstaged,
              staged = lvim.ui.icons.git.FileStaged,
              conflict = lvim.ui.icons.git.FileConflict,
            },
          },
        },
        document_symbols = {
          follow_cursor = true,
          kinds = {
            File = { icon = lvim.ui.icons.kind.File, hl = "Tag" },
            Namespace = { icon = lvim.ui.icons.kind.Namespace, hl = "Include" },
            Package = { icon = lvim.ui.icons.kind.Package, hl = "Label" },
            Class = { icon = lvim.ui.icons.kind.Class, hl = "Include" },
            Property = { icon = lvim.ui.icons.kind.Property, hl = "@property" },
            Enum = { icon = lvim.ui.icons.kind.Enum, hl = "@number" },
            Function = { icon = lvim.ui.icons.kind.Function, hl = "Function" },
            String = { icon = lvim.ui.icons.kind.String, hl = "String" },
            Number = { icon = lvim.ui.icons.kind.Number, hl = "Number" },
            Array = { icon = lvim.ui.icons.kind.Array, hl = "Type" },
            Object = { icon = lvim.ui.icons.kind.Object, hl = "Type" },
            Key = { icon = lvim.ui.icons.kind.Key, hl = "" },
            Struct = { icon = lvim.ui.icons.kind.Struct, hl = "Type" },
            Operator = { icon = lvim.ui.icons.kind.Operator, hl = "Operator" },
            TypeParameter = { icon = lvim.ui.icons.kind.TypeParameter, hl = "Type" },
            StaticMethod = { icon = lvim.ui.icons.kind.Method, hl = "Function" },
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
            ["zC"] = "close_all_nodes",
            ["zO"] = "expand_all_nodes",
            ["r"] = "rename",
            ["q"] = "close_window",
            ["R"] = "refresh",
            ["?"] = "show_help",
          },
        },
        nesting_rules = {
          ["js"] = { "js.map", "d.ts" },
        },
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
            },
          },
          follow_current_file = false,
          -- follow_current_file = {
          --   enabled = true, -- This will find and focus the file in the active buffer every time
          --   --               -- the current file is changed while the tree is open.
          --   leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          -- },
          -- time the current file is changed while the tree is open.
          group_empty_dirs = false, -- when true, empty folders will be grouped together
          hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          enable_buffer_write_refresh = true,
          enable_refresh_on_write = false, -- Refresh the tree when a file is written. Only used if `use_libuv_file_watcher` is false.
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ["d"] = "delete",
              ["y"] = "copy_to_clipboard",
              ["Y"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
              ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
              ["a"] = {
                "add",
                -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                config = {
                  show_path = "none", -- "none", "relative", "absolute"
                },
              },
              ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
              ["x"] = "cut_to_clipboard",
              ["p"] = "paste_from_clipboard",
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
              ["c"] = "copy_filename",
              ["C"] = "copy_filepath",
              ["HH"] = "prev_sibling",
              ["LL"] = "next_sibling",
              ["H"] = "parent",
            },
          },
          commands = {
            system_open = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              -- macOs: open file in default application in the background.
              -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
              -- vim.cmd("silent !open -g " .. path)
              -- Linux: open file in default application

              vim.cmd(string.format("silent !xdg-open '%s'", path))
            end,
            copy_filename = function(state)
              local node = state.tree:get_node()

              vim.fn.setreg(system_register, node.name, "c")
            end,
            copy_filepath = function(state)
              local node = state.tree:get_node()
              local full_path = node.path
              local relative_path = full_path:sub(#state.path + 2)

              vim.fn.setreg(system_register, relative_path, "c")
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
            next_sibling = function(state)
              local node = state.tree:get_node()
              local siblings = get_siblings(state, node)
              if not node.is_last_child then
                local current = index_of(siblings, node.id)
                local next = siblings[current + 1]
                renderer.focus_node(state, next)
              end
            end,
            prev_sibling = function(state)
              local node = state.tree:get_node()
              local siblings = get_siblings(state, node)
              local current = index_of(siblings, node.id)
              if current > 1 then
                local next = siblings[current - 1]
                renderer.focus_node(state, next)
              end
            end,
            parent = function(state)
              local node = state.tree:get_node()
              local parent_path, _ = require("neo-tree.utils").split_path(node:get_id())
              renderer.focus_node(state, parent_path)
            end,
          },
        },
        buffers = {
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
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
              ["GG"] = "git_commit_and_push",
            },
          },
        },
      }

      -- add external sources
      if fn.is_extension_enabled("miversen33/netman.nvim") then
        table.insert(setup.sources, "netman.ui.neo-tree")
        table.insert(setup.source_selector.sources, { source = "netman.ui.neo-tree", display_name = (" %s Remote "):format(lvim.ui.icons.kind.Struct) })
      end

      return setup
    end,
    on_setup = function(config)
      require("neo-tree").setup(config.setup)
    end,
    wk = function(_, categories)
      local Log = require("lvim.core.log")

      return {
        ["E"] = {
          function()
            if M.source == "" then
              return vim.cmd([[Neotree focus]])
            end

            return vim.cmd(([[Neotree focus source=%s]]):format(M.source))
          end,
          "focus filetree",
        },
        ["e"] = {
          function()
            if M.source == "" then
              return vim.cmd([[Neotree toggle]])
            end

            return vim.cmd(([[Neotree toggle source=%s]]):format(M.source))
          end,
          "open filetree",
        },
        [","] = { ":Neotree reveal<CR>", "reveal file in filetree" },
        ["."] = { ":Neotree position=right buffers toggle<CR>", "open buffers in filetree" },
        ["?"] = {
          function()
            local sources = { "filesystem", "remote", "buffers", "git_status", "document_symbols" }

            vim.ui.select(sources, {
              prompt = "Change tree source: ",
              default = M.source,
            }, function(source)
              if source == nil then
                return
              end

              Log:info(("Source switched for tree: %s"):format(source))

              M.source = source
            end)
          end,
          "select tree source",
        },
        [categories.GIT] = {
          ["e"] = { ":Neotree position=right git_status toggle<CR>", "git files in filetree" },
        },
        [categories.LSP] = {
          o = {
            ":Neotree source=document_symbols right toggle<CR>",
            "toggle outline",
          },
        },
      }
    end,
  })
end

M.source = ""

return M
