--
local M = {}

local extension_name = "dadbod"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    plugin = function()
      return {
        {
          "tpope/vim-dadbod",
          cmd = { "DB" },
        },
        {
          "kristijanhusak/vim-dadbod-ui",
          cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        },
        {
          "kristijanhusak/vim-dadbod-completion",
          ft = { "sql", "mysql", "plsql" },
        },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "dbout",
        "dbui",
      })

      require("modules.autocmds").q_close_autocmd({ "dbout" })
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
    autocmds = {
      {
        "FileType",
        {
          group = "__dadbod",
          pattern = { "sql", "mysql", "plsql" },
          callback = function()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
          end,
        },
      },
    },
    wk = function(_, categories)
      return {
        [categories.TASKS] = {
          ["b"] = {
            function()
              require("lazy").load({ plugins = { "vim-dadbod" } })
              vim.cmd([[DBUIToggle]])
            end,
            "dadbod",
          },
          ["B"] = {
            "<Plug>(DBUI_JumpToForeignKey)",
            "dadbod - jump to foreign key",
          },
        },
      }
    end,
  })
end

return M
