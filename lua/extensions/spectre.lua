-- https://github.com/nvim-pack/nvim-spectre
local M = {}

local extension_name = "spectre"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "nvim-pack/nvim-spectre",
        run = "./build.sh",
        config = function()
          require("utils.setup").packer_config "spectre"
        end,
        disable = not config.active,
      }
    end,
    configure = function()
      table.insert(lvim.disabled_filetypes, "spectre_panel")
    end,
    to_inject = function()
      return {
        spectre = require "spectre",
      }
    end,
    setup = {
      color_devicons = true,
      highlight = { ui = "String", search = "SpectreChange", replace = "Spec.red[600]elete" },
      live_update = true,
      mapping = {
        ["delete_line"] = {
          map = "D",
          cmd = ":lua require('spectre').toggle_line()<CR>",
          desc = "toggle current item",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = ":lua require('spectre.actions').select_entry()<CR>",
          desc = "goto current file",
        },
        ["send_to_qf"] = {
          map = "Q",
          cmd = ":lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all item to quickfix",
        },
        ["replace_cmd"] = {
          map = "C",
          cmd = ":lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace vim command",
        },
        ["show_option_menu"] = {
          map = "o",
          cmd = ":lua require('spectre').show_options()<CR>",
          desc = "show option",
        },
        ["run_current_replace"] = {
          map = "S",
          cmd = ":lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line",
        },
        ["run_replace"] = {
          map = "R",
          cmd = ":lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all",
        },
        ["change_view_mode"] = {
          map = "v",
          cmd = ":lua require('spectre').change_view()<CR>",
          desc = "change result view mode",
        },
        ["change_replace_sed"] = {
          map = "zO",
          cmd = ":lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed to replace",
        },
        ["change_replace_oxi"] = {
          map = "zo",
          cmd = ":lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi to replace",
        },
        ["toggle_ignore_case"] = {
          map = "zi",
          cmd = ":lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case",
        },
        ["toggle_ignore_hidden"] = {
          map = "zh",
          cmd = ":lua require('spectre').change_options('hidden')<CR>",
          desc = "toggle search hidden",
        },
        ["toggle_string_search"] = {
          map = "zs",
          cmd = ":lua require('spectre').change_options('string')<CR>",
          desc = "toggle string search mode",
        },
        ["toggle_live_update"] = {
          map = "zu",
          cmd = ":lua require('spectre').toggle_live_update()<CR>",
          desc = "update change when vim write file.",
        },
        ["resume_last_search"] = {
          map = "zl",
          cmd = ":lua require('spectre').resume_last_search()<CR>",
          desc = "resume last search before close",
        },
        -- you can put your mapping here it only have normal
      },
      find_engine = {
        -- rg is map with finder_cmd
        ["rg"] = {
          cmd = "rg",
          -- default args
          args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
          options = {
            ["ignore-case"] = { value = "--ignore-case", desc = "ignore case", icon = "[I]" },
            ["hidden"] = { value = "--hidden", desc = "hidden file", icon = "[H]" },
            ["string"] = { value = "--fixed-strings", desc = "fixed string mode", icon = "[S]" },
            -- you can put any option you want here it can toggle with
            -- show_option function
          },
        },
      },
      replace_engine = {
        ["sed"] = {
          cmd = "sed",
          args = nil,
          options = {
            ["ignore-case"] = { value = "--ignore-case", icon = "[I]", desc = "ignore case" },
            ["string"] = { value = "--string-mode", desc = "fixed string mode", icon = "[S]" },
          },
        },

        ["sd"] = {
          cmd = "sd",
          args = nil,
          options = {
            ["ignore-case"] = { value = "-f c", icon = "[I]", desc = "ignore case" },
            ["string"] = { value = "--string-mode", desc = "fixed string mode", icon = "[S]" },
          },
        },

        -- call rust code by nvim-oxi to replace
        ["oxi"] = {
          cmd = "oxi",
          args = {},
          options = {
            ["ignore-case"] = {
              value = "i",
              icon = "[I]",
              desc = "ignore case",
            },
          },
        },
      },
      default = {
        find = {
          -- pick one of item that find_engine
          cmd = "rg",
          options = { "ignore-case" },
        },
        replace = {
          -- pick one of item that replace_engine
          cmd = "oxi",
        },
      },
      replace_vim_cmd = "cfdo",
      is_open_target_win = true, -- open file on opener window
      is_insert_mode = false, -- start open panel on is_insert_mode
    },
    on_setup = function(config)
      require("spectre").setup(config.setup)
    end,
    keymaps = function(config)
      local spectre = config.inject.spectre
      return {
        n = {
          ["sa"] = { spectre.open_file_search, { desc = "search and replace in current file" } },
          ["as"] = { spectre.open, { desc = "search and replace" } },
        },
        v = {
          ["sa"] = { spectre.open_file_search, { desc = "search and replace in current file" } },
          ["as"] = { spectre.open, { desc = "search and replace" } },
        },
      }
    end,
    wk = function(config)
      local spectre = config.inject.spectre
      return {
        -- find and replace
        s = {
          name = "find & replace",
          f = {
            function()
              spectre.open()
            end,
            "find and replace",
          },
          v = {
            function()
              spectre.open_visual()
            end,
            "find the word under cursor and replace",
          },
          b = {
            function()
              spectre.open_file_search()
            end,
            "find and replace in current buffer",
          },
        },
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__spectre",
          pattern = "spectre_panel",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0",
        },
      },
    },
  })
end

return M
