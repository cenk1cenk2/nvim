-- https://github.com/jedrzejboczar/possession.nvim
local M = {}
local Log = require("lvim.core.log")

local extension_name = "jedrzejboczar/possession.nvim"

local session_dir = join_paths(get_data_dir(), "sessions")

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "jedrzejboczar/possession.nvim",
        cmd = {
          "PossessionSave",
          "PossessionLoad",
          "PossessionRename",
          "PossessionClose",
          "PossessionDelete",
          "PossessionShow",
          "PossessionList",
          "PossessionMigrate",
        },
      }
    end,
    setup = function()
      return {
        session_dir = session_dir,
        silent = true,
        load_silent = true,
        debug = false,
        logfile = false,
        prompt_no_cr = false,
        autosave = {
          current = true, -- or fun(name): boolean
          tmp = false, -- or fun(): boolean
          tmp_name = "tmp", -- or fun(): string
          on_load = true,
          on_quit = true,
        },
        hooks = {
          before_save = function(name)
            local res = {}
            local neo_state = M.neotree_get_state()
            if neo_state ~= nil then
              res["neo_tree"] = neo_state
            end
            return res
          end,
          after_save = function(name, user_data, aborted) end,
          before_load = function(name, user_data)
            return user_data
          end,
          after_load = function(name, user_data)
            if user_data["neo_tree"] ~= nil then
              M.neotree_set_state(user_data["neo_tree"])
            end
          end,
        },
        plugins = {
          close_windows = {
            hooks = { "before_save", "before_load" },
            preserve_layout = true, -- or fun(win): boolean
            match = {
              floating = true,
              buftype = {},
              filetype = {},
              custom = false, -- or fun(win): boolean
            },
          },
          delete_hidden_buffers = {
            hooks = {
              "before_load",
              not vim.o.sessionoptions:match("buffer") and "before_save",
            },
            force = false, -- or fun(buf): boolean
          },
          nvim_tree = true,
          neo_tree = true,
          symbols_outline = true,
          tabby = true,
          dap = true,
          dapui = true,
          neotest = true,
          delete_buffers = false,
        },
        telescope = {
          list = {
            default_action = "load",
            mappings = {
              save = { n = "<c-s>", i = "<c-s>" },
              load = { n = "<c-l>", i = "<c-l>" },
              delete = { n = "<c-d>", i = "<c-d>" },
              rename = { n = "<c-r>", i = "<c-r>" },
            },
          },
        },
      }
    end,
    on_setup = function(config)
      require("possession").setup(config.setup)
    end,
    on_done = function()
      require("telescope").load_extension("possession")
    end,
    wk = function(_, categories)
      return {
        [categories.SESSION] = {
          d = {
            function()
              local cwd = vim.fn.getcwd()
              local session = M.dir_to_session_filename(cwd)
              local stat = vim.uv.fs_stat(M.session_to_full_path(("%s.json"):format(session)))

              if stat == nil or stat.type ~= "file" then
                Log:warn(("Session does not exist: %s -> %s"):format(cwd, session))

                return
              end

              require("possession.session").delete(session)
            end,
            "delete sessions",
          },
          l = {
            function()
              local cwd = vim.fn.getcwd()
              local session = M.dir_to_session_filename(cwd)
              local stat = vim.uv.fs_stat(M.session_to_full_path(("%s.json"):format(session)))

              if stat == nil or stat.type ~= "file" then
                Log:warn(("Session does not exist: %s -> %s"):format(cwd, session))

                return
              end

              require("possession.session").load(session)
            end,
            "load cwd last session",
          },
          s = {
            function()
              local cwd = vim.fn.getcwd()
              local session = M.dir_to_session_filename(cwd)

              require("possession.session").save(session, { no_confirm = true })

              Log:info(("Session saved: %s -> %s"):format(cwd, session))
            end,
            "save session",
          },
          f = {
            function()
              require("telescope").extensions.possession.list()
            end,
            "list sessions",
          },
        },
      }
    end,
  })
end

local path_replacer = "__"
local colon_replacer = "++"

function M.dir_to_session_filename(dir)
  local Path = require("plenary.path")

  local filename = dir:gsub(":", colon_replacer)
  filename = filename:gsub(Path.path.sep, path_replacer)

  return filename
end

function M.session_to_full_path(session)
  -- local config = M.current_setup()

  return join_paths(session_dir, session)
end

--[[ *possession* ]]
function M.neotree_expand_dirs(dir_paths, dir_i)
  if dir_i > #dir_paths then
    return
  end
  local cur_dir_path = dir_paths[dir_i]
  vim.loop.fs_opendir(cur_dir_path, function(err, dir)
    if err then
      print(cur_dir_path, ": ", err)
      M.neotree_expand_dirs(dir_paths, dir_i + 1)
      return
    end
    vim.loop.fs_readdir(dir, function(err, entries)
      if entries[1] ~= nil then
        vim.schedule(function()
          local utils = require("neo-tree.utils")
          local manager = require("neo-tree.sources.manager")
          local filesystem = require("neo-tree.sources.filesystem")

          local state = manager.get_state("filesystem")
          local child_path = utils.path_join(cur_dir_path, entries[1].name)
          filesystem._navigate_internal(state, state.path, child_path, function()
            state.explicitly_opened_directories = state.explicitly_opened_directories or {}
            state.explicitly_opened_directories[cur_dir_path] = true
            M.neotree_expand_dirs(dir_paths, dir_i + 1)
          end)
        end)
      end
    end)
  end)
end

function M.neotree_get_state()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) == "neo-tree" and next(vim.fn.win_findbuf(bufnr)) then
      local utils = require("neo-tree.utils")
      local manager = require("neo-tree.sources.manager")
      local filesystem = require("neo-tree.sources.filesystem")

      local state = manager.get_state("filesystem")
      local expanded_dirs = {}
      if state.explicitly_opened_directories ~= nil then
        for cur_dir, is_expanded in pairs(state.explicitly_opened_directories) do
          if is_expanded then
            table.insert(expanded_dirs, cur_dir)
          end
        end
      end
      return { path = state.path, expanded_dirs = expanded_dirs, show_hidden = state.filtered_items.visible }
    end
  end
end

function M.neotree_set_state(data)
  require("neo-tree.command").execute({
    action = "show",
    dir = data["path"],
  })
  if data["show_hidden"] then
    local manager = require("neo-tree.sources.manager")
    local state = manager.get_state("filesystem")
    state.filtered_items.visible = true
  end
  M.neotree_expand_dirs(data["expanded_dirs"], 1)
end

M.current_setup = require("utils.setup").fn.get_current_setup_wrapper(extension_name)

return M
