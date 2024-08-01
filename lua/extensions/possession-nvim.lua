-- https://github.com/jedrzejboczar/possession.nvim
local M = {}

local extension_name = "jedrzejboczar/possession.nvim"

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
        session_dir = join_paths(get_data_dir(), "sessions"),
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
            -- pcall(function()
            --   vim.cmd([[AerialCloseAll]])
            -- end)

            local res = {}
            -- local neo_state = M.neotree_get_state()
            -- if neo_state ~= nil then
            --   res["neo_tree"] = neo_state
            -- end
            return res
          end,
          after_save = function(name, user_data, aborted) end,
          before_load = function(name, user_data)
            return user_data
          end,
          after_load = function(name, user_data)
            -- if user_data["neo_tree"] ~= nil then
            --   M.neotree_set_state(user_data["neo_tree"])
            -- end
          end,
        },
        plugins = {
          close_windows = {
            hooks = { "before_save", "before_load" },
            preserve_layout = false, -- or fun(win): boolean
            match = {
              floating = true,
              buftype = lvim.disabled_buffer_types,
              filetype = lvim.disabled_filetypes,
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
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.SESSION, "d" }),
          function()
            require("possession.session").delete(require("possession.paths").cwd_session_name())
          end,
          desc = "delete sessions",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "l" }),
          function()
            require("possession.session").load(require("possession.paths").cwd_session_name())
          end,
          desc = "load cwd last session",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "s" }),
          function()
            require("possession.session").save(require("possession.paths").cwd_session_name(), { no_confirm = true })
          end,
          desc = "save session",
        },
        {
          fn.wk_keystroke({ categories.SESSION, "f" }),
          function()
            require("telescope").extensions.possession.list()
          end,
          desc = "list sessions",
        },
      }
    end,
  })
end

M.current_setup = require("utils.setup").fn.get_current_setup_wrapper(extension_name)

return M
