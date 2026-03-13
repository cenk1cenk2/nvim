-- https://github.com/kndndrj/nvim-dbee
local M = {}

M.name = "kndndrj/nvim-dbee"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "kndndrj/nvim-dbee",
        build = function()
          require("dbee").install()
        end,
        dependencies = {
          {
            "MattiasMTS/cmp-dbee",
            ft = { "sql", "mysql", "plsql" },
            enabled = is_enabled(require("ck.plugins.blink-cmp").name),
            init = function()
              require("ck.setup").setup_callback(require("ck.plugins.blink-cmp").name, function(c)
                c.sources.providers.dbee = {
                  module = "blink.compat.source",
                  name = "cmp-dbee",
                }

                c.sources.per_filetype.sql = { "dbee" }
                c.sources.per_filetype.mysql = { "dbee" }
                c.sources.per_filetype.plsql = { "dbee" }

                return c
              end)
            end,
            config = function()
              require("cmp-dbee").setup({})
            end,
          },
        },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.possession-nvim").name, function(c)
        local before_save = c.hooks.before_save
        c.hooks.before_save = function(name)
          pcall(function()
            if is_loaded("dbee") then
              require("dbee").close()
            end
          end)

          return before_save(name)
        end

        return c
      end)

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.right, {
          {
            ft = "dbee",
            title = "Database",
            size = {
              width = function()
                if vim.o.columns < 180 then
                  return math.floor(vim.o.columns * 0.3)
                end

                return 80
              end,
            },
            filter = function(buf)
              return not vim.api.nvim_buf_get_name(buf):find("^dbee-result.*")
            end,
          },
        })

        vim.list_extend(c.bottom, {
          {
            ft = "dbee-result",
            title = "Database",
            size = {
              width = function()
                if vim.o.rows < 60 then
                  return math.floor(vim.o.columns * 0.25)
                end

                return 50
              end,
            },
            filter = function(buf)
              return vim.api.nvim_buf_get_name(buf):find("^dbee-result.*")
            end,
          },
        })

        return c
      end)

      fn.add_disabled_filetypes({
        "dbee",
        "dbee-result",
      })
    end,
    setup = function(_, fn)
      ---@type Config
      return {
        sources = {
          require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
          require("dbee.sources").FileSource:new(join_paths(get_data_dir(), "/dbee/persistence.json")),
        },
        drawer = {
          mappings = {
            -- manually refresh drawer
            { key = fn.local_keystroke({ "Q" }), mode = "n", action = "refresh" },
            -- actions perform different stuff depending on the node:
            -- action_1 opens a note or executes a helper
            { key = "<CR>", mode = "n", action = "action_1" },
            -- action_2 renames a note or sets the connection as active manually
            { key = fn.local_keystroke({ "c" }), mode = "n", action = "action_2" },
            -- action_3 deletes a note or connection (removes connection from the file if you configured it like so)
            { key = fn.local_keystroke({ "X" }), mode = "n", action = "action_3" },
            -- these are self-explanatory:
            -- { key = "c", mode = "n", action = "collapse" },
            -- { key = "e", mode = "n", action = "expand" },
            { key = fn.local_keystroke({ "o" }), mode = "n", action = "toggle" },
            -- mappings for menu popups:
            { key = "<CR>", mode = "n", action = "menu_confirm" },
            { key = "y", mode = "n", action = "menu_yank" },
            { key = "<Esc>", mode = "n", action = "menu_close" },
            { key = "q", mode = "n", action = "menu_close" },
          },
        },
        result = {
          mappings = {
            -- next/previous page
            { key = fn.local_keystroke({ "n" }), mode = "", action = "page_next" },
            { key = fn.local_keystroke({ "p" }), mode = "", action = "page_prev" },
            { key = fn.local_keystroke({ "N" }), mode = "", action = "page_last" },
            { key = fn.local_keystroke({ "P" }), mode = "", action = "page_first" },
            -- yank rows as csv/json
            { key = "yaj", mode = "n", action = "yank_current_json" },
            { key = "yaj", mode = "v", action = "yank_selection_json" },
            { key = "yaJ", mode = "", action = "yank_all_json" },
            { key = "yac", mode = "n", action = "yank_current_csv" },
            { key = "yac", mode = "v", action = "yank_selection_csv" },
            { key = "yaC", mode = "", action = "yank_all_csv" },

            -- cancel current call execution
            { key = "<C-c>", mode = "", action = "cancel_call" },
          },
          buffer_options = {
            filetype = "dbee-result",
          },
        },
        editor = {
          mappings = {
            -- run what's currently selected on the active connection
            { key = fn.local_keystroke({ "r" }), mode = "v", action = "run_selection" },
            -- run the whole file on the active connection
            { key = fn.local_keystroke({ "R" }), mode = "n", action = "run_file" },
          },
        },
      }
    end,
    on_setup = function(c)
      require("dbee").setup(c)
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "b" }),
          function()
            require("dbee").toggle()
          end,
          desc = "dbee toggle",
        },
      }
    end,
  })
end

return M
