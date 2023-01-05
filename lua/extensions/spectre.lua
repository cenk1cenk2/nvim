-- https://github.com/nvim-pack/nvim-spectre
local M = {}

local extension_name = "spectre"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "nvim-pack/nvim-spectre",
        dependencies = {
          { "nvim-lua/plenary.nvim" },
        },
        build = { "./build.sh" },
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "spectre_panel",
      })
    end,
    setup = {
      color_devicons = true,
      highlight = { ui = "String", search = "SpectreChange", replace = "SpectreDelete" },
      live_update = true,
      default = {
        find = {
          -- pick one of item that find_engine
          cmd = "rg",
          options = { "ignore-case" },
        },
        replace = {
          -- pick one of item that replace_engine
          cmd = "sed",
        },
      },
      replace_vim_cmd = "cfdo",
      is_open_target_win = true, -- open file on opener window
      is_insert_mode = false, -- start open panel on is_insert_mode
    },
    on_setup = function(config)
      require("spectre").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        -- find and replace
        [categories.SEARCH] = {
          s = {
            function()
              require("spectre").open()
            end,
            "find and replace",
          },
          w = {
            function()
              require("spectre").open({ path = string.format("%s/**", vim.fn.expand("%:h")) })
            end,
            "find and replace in current folder",
          },
          v = {
            function()
              require("spectre").open_visual({ select_word = true })
            end,
            "find the word under cursor and replace",
          },
          b = {
            function()
              require("spectre").open_file_search()
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
