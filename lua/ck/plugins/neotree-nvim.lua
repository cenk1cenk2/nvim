-- https://github.com/nvim-neo-tree/neo-tree.nvim
local M = {}

M.name = "nvim-neo-tree/neo-tree.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "main",
        dependencies = {
          "nvim-lua/plenary.nvim",
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
    setup = function()
      local log = require("ck.log")
      local system_register = nvim.system_register

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
          log:warn("Finding in node only works for files and directories.")
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
            { source = "filesystem", display_name = (" %s Files "):format(nvim.ui.icons.ui.Folder) },
            -- { source = "buffers", display_name = (" %s Buffers "):format(nvim.ui.icons.ui.File) },
            -- { source = "git_status", display_name = (" %s Git "):format(nvim.ui.icons.ui.Git) },
            -- { source = "document_symbols", display_name = (" %s Symbols "):format(nvim.ui.icons.kind.Function) },
          },
        },
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        enable_cursor_hijack = false, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
        popup_border_style = nvim.ui.border,
        -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/338
        enable_diagnostics = false,
        enable_git_status = true,
        enable_modified_markers = true, -- Show markers for files with unsaved changes.sort_case_insensitive = true, -- used when sorting files and directories in the tree
        enable_opened_markers = true,
        open_files_do_not_replace_types = nvim.disabled_filetypes, -- when opening files, do not use windows containing these filetypes or buftypes
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
            indent_marker = nvim.ui.icons.ui.LineMiddle,
            last_indent_marker = nvim.ui.icons.ui.LineMiddleEnd,
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = nvim.ui.icons.ui.ChevronShortRight,
            expander_expanded = nvim.ui.icons.ui.ChevronShortDown,
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            -- folder_closed = nvim.ui.icons.ui.Folder,
            -- folder_open = nvim.ui.icons.ui.FolderOpen,
            -- folder_empty = nvim.ui.icons.ui.EmptyFolder,
            -- default = nvim.ui.icons.ui.File,
            -- highlight = "NeoTreeFileIcon",
          },
          modified = {
            symbol = nvim.ui.icons.git.LineModified,
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
              added = nvim.ui.icons.git.FileAdded,
              deleted = nvim.ui.icons.git.FileDeleted,
              modified = nvim.ui.icons.git.FileModified,
              renamed = nvim.ui.icons.git.FileRenamed,
              -- Status type
              untracked = nvim.ui.icons.git.FileUntracked,
              ignored = nvim.ui.icons.git.FileIgnored,
              unstaged = nvim.ui.icons.git.FileUnstaged,
              staged = nvim.ui.icons.git.FileStaged,
              conflict = nvim.ui.icons.git.FileConflict,
            },
          },
        },
        document_symbols = {
          follow_cursor = true,
          kinds = {
            File = { icon = nvim.ui.icons.kind.File, hl = "Tag" },
            Namespace = { icon = nvim.ui.icons.kind.Namespace, hl = "Include" },
            Package = { icon = nvim.ui.icons.kind.Package, hl = "Label" },
            Class = { icon = nvim.ui.icons.kind.Class, hl = "Include" },
            Property = { icon = nvim.ui.icons.kind.Property, hl = "@property" },
            Enum = { icon = nvim.ui.icons.kind.Enum, hl = "@number" },
            Function = { icon = nvim.ui.icons.kind.Function, hl = "Function" },
            String = { icon = nvim.ui.icons.kind.String, hl = "String" },
            Number = { icon = nvim.ui.icons.kind.Number, hl = "Number" },
            Array = { icon = nvim.ui.icons.kind.Array, hl = "Type" },
            Object = { icon = nvim.ui.icons.kind.Object, hl = "Type" },
            Key = { icon = nvim.ui.icons.kind.Key, hl = "" },
            Struct = { icon = nvim.ui.icons.kind.Struct, hl = "Type" },
            Operator = { icon = nvim.ui.icons.kind.Operator, hl = "Operator" },
            TypeParameter = { icon = nvim.ui.icons.kind.TypeParameter, hl = "Type" },
            StaticMethod = { icon = nvim.ui.icons.kind.Method, hl = "Function" },
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
          -- follow_current_file = false,
          follow_current_file = {
            enabled = false, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
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
              ["K"] = "show_file_details2",
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

              if OS_UNAME == "darwin" then
                vim.fn.jobstart({ "open", path }) -- Mac OS
              else
                vim.fn.jobstart({ "xdg-open", path }) -- linux
              end
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
            show_file_details2 = function(state)
              local node = state.tree:get_node()
              if node.type == "message" then
                return
              end

              -- local utils = require("neo-tree.utils")
              local popups = require("neo-tree.ui.popups")

              -- local stat = utils.get_stat(node)
              local left = {}
              local right = {}
              table.insert(left, "Name")
              table.insert(right, node.name)
              table.insert(left, "Path")
              table.insert(right, vim.fn.fnamemodify(node:get_id(), ":p:~:."))
              table.insert(left, "Type")
              table.insert(right, node.type)
              -- if stat.size then
              --   table.insert(left, "Size")
              --   table.insert(right, utils.human_size(stat.size))
              --   table.insert(left, "Created")
              --   table.insert(right, os.date("%Y-%m-%d %I:%M %p", stat.birthtime.sec))
              --   table.insert(left, "Modified")
              --   table.insert(right, os.date("%Y-%m-%d %I:%M %p", stat.mtime.sec))
              -- end

              local lines = {}
              for i, v in ipairs(left) do
                local line = string.format("%9s: %s", v, right[i])
                table.insert(lines, line)
              end

              popups.alert("File Details", lines)
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

      return setup
    end,
    on_setup = function(c)
      require("neo-tree").setup(c)
    end,
    wk = function(_, categories, fn)
      local log = require("ck.log")

      return {
        {
          fn.wk_keystroke({ "e" }),
          function()
            if M.source == "" then
              return vim.cmd([[Neotree toggle]])
            end

            return vim.cmd(([[Neotree toggle source=%s]]):format(M.source))
          end,
          desc = "open filetree",
        },
        {
          fn.wk_keystroke({ "E" }),
          function()
            if M.source == "" then
              return vim.cmd([[Neotree focus]])
            end

            return vim.cmd(([[Neotree focus source=%s]]):format(M.source))
          end,
          desc = "focus filetree",
        },
        {
          fn.wk_keystroke({ "," }),
          function()
            vim.cmd([[Neotree reveal]])
          end,
          desc = "reveal file in filetree",
        },
        {
          fn.wk_keystroke({ "." }),
          function()
            vim.cmd([[Neotree position=right buffers toggle]])
          end,
          desc = "open buffers in filetree",
        },
        {
          fn.wk_keystroke({ "?" }),
          function()
            local sources = { "filesystem", "remote", "buffers", "git_status", "document_symbols" }

            vim.ui.select(sources, {
              prompt = "Change tree source: ",
              default = M.source,
            }, function(source)
              if source == nil then
                return
              end

              log:info(("Source switched for tree: %s"):format(source))

              M.source = source
            end)
          end,
          desc = "select tree source",
        },
        {
          fn.wk_keystroke({ categories.GIT, "e" }),
          function()
            vim.cmd([[Neotree position=right git_status toggle]])
          end,
          desc = "git file explorer",
        },
        -- {
        --   fn.wk_keystroke({ categories.LSP, "o" }),
        --   function ()
        --     vim.cmd([[Neotree source=document_symbols right toggle]])
        --   end,
        --   desc = "toggle outline"
        -- },

        {
          fn.wk_keystroke({ categories.BUFFER, "f" }),
          group = "filesystem",
        },

        {
          fn.wk_keystroke({ categories.BUFFER, "f", "c" }),
          function()
            require("neo-tree.sources.filesystem.lib.fs_actions").create_node(require("ck.utils.fs").get_buffer_dirpath())
          end,
          desc = "create file relative to current buffer in filesystem",
        },

        {
          fn.wk_keystroke({ categories.BUFFER, "f", "d" }),
          function()
            require("neo-tree.sources.filesystem.lib.fs_actions").delete_node(require("ck.utils.fs").get_buffer_filepath())
          end,
          desc = "delete current buffer from filesystem",
        },

        {
          fn.wk_keystroke({ categories.BUFFER, "f", "m" }),
          function()
            require("neo-tree.sources.filesystem.lib.fs_actions").move_node(require("ck.utils.fs").get_buffer_filepath())
          end,
          desc = "move current buffer in filesystem",
        },

        {
          fn.wk_keystroke({ categories.BUFFER, "f", "r" }),
          function()
            require("neo-tree.sources.filesystem.lib.fs_actions").rename_node(require("ck.utils.fs").get_buffer_filepath())
          end,
          desc = "rename current buffer in filesystem",
        },

        {
          fn.wk_keystroke({ categories.BUFFER, "f", "y" }),
          function()
            require("neo-tree.sources.filesystem.lib.fs_actions").copy_node(require("ck.utils.fs").get_buffer_filepath())
          end,
          desc = "copy current buffer in filesystem",
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({
          "neo-tree-preview",
          "neo-tree-popup",
        }),
      }
    end,
  })
end

M.source = ""

return M
