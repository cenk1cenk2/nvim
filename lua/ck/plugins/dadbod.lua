--https://github.com/tpope/vim-dadbod
local M = {}

M.name = "tpope/vim-dadbod"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "tpope/vim-dadbod",
        cmd = { "DB" },
        dependencies = {
          {
            "kristijanhusak/vim-dadbod-ui",
            cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
          },
          {
            "kristijanhusak/vim-dadbod-completion",
            ft = { "sql", "mysql", "plsql" },
          },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "dbout",
        "dbui",
      })

      fn.setup_callback(require("ck.plugins.edgy-nvim").name, function(c)
        vim.list_extend(c.left, {
          {
            ft = "dbui",
            title = "DadBod-UI",
          },
        })

        vim.list_extend(c.bottom, {
          {
            ft = "dbout",
            title = "DadBod-Out",
          },
        })

        return c
      end)
    end,
    legacy_setup = {
      db_ui_use_nerd_fonts = 1,
      db_ui_save_location = get_data_dir() .. "/" .. "dadbod",
      db_ui_winwidth = 50,
      db_ui_table_helpers = {
        postgresql = {
          List = "select * from {table}",
        },
      },
    },
    on_done = function()
      if is_enabled(require("ck.plugins.cmp").name) then
        require("cmp").setup.filetype({
          "sql",
          "mysql",
          "plsql",
          "psql",
        }, {
          sources = {
            { name = "vim-dadbod-completion" },
          },
        })
      end
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.RUN, "b" }),
          function()
            require("lazy").load({ plugins = { "vim-dadbod" } })
            vim.cmd([[DBUIToggle]])
          end,
          desc = "dadbod",
        },
        {
          fn.wk_keystroke({ categories.RUN, "B" }),
          "<Plug>(DBUI_JumpToForeignKey)",
          desc = "dadbod - jump to foreign key",
        },
      }
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").q_close_autocmd({ "dbout" }),
      }
    end,
  })
end

return M
