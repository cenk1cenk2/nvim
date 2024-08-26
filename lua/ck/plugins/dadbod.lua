--https://github.com/tpope/vim-dadbod
local M = {}

M.name = "tpope/vim-dadbod"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
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
    autocmds = function()
      return {
        {
          event = "FileType",
          group = "__dadbod",
          pattern = { "sql", "mysql", "plsql" },
          callback = function()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end,
        },
      }
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.TASKS, "b" }),
          function()
            require("lazy").load({ plugins = { "vim-dadbod" } })
            vim.cmd([[DBUIToggle]])
          end,
          desc = "dadbod",
        },
        {
          fn.wk_keystroke({ categories.TASKS, "B" }),
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
