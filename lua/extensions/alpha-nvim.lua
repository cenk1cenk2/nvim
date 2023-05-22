-- https://github.com/goolord/alpha-nvim
local M = {}

local extension_name = "alpha"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "goolord/alpha-nvim",
        lazy = false,
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "alpha",
      })
    end,
    on_setup = function(config)
      local button = require("alpha.themes.dashboard").button

      local buttons = {}
      for _, value in ipairs(config.layout.buttons) do
        table.insert(buttons, button(value[1], value[2]))
      end

      require("alpha").setup({
        layout = {
          { type = "padding", val = 1 },
          {
            type = "text",
            val = config.layout.header,
            opts = {
              position = "center",
              hl = "DashboardHeader",
              -- wrap = "overflow";
            },
          },
          { type = "padding", val = 1 },
          {
            type = "group",
            val = buttons,
            opts = {
              spacing = 1,
              hl = "DashboardCenter",
            },
          },
          { type = "padding", val = 1 },

          {
            type = "text",
            val = function()
              local stats = require("lazy").stats()

              return { ("%s %d/%d plugins in %s %.0fms"):format(lvim.ui.icons.ui.Package, stats.loaded, stats.count, lvim.ui.icons.misc.Watch, stats.startuptime) }
            end,
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { ("%s %s#%s"):format(lvim.ui.icons.git.Branch, require("lvim.utils.git").get_lvim_branch(), require("lvim.utils.git").get_lvim_current_sha()) },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { ("%s %s"):format(lvim.ui.icons.ui.Gear, require("lvim.utils.git").get_nvim_version()) },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
        },
        opts = {
          margin = 5,
        },
      })
    end,
    wk = function(_, categories)
      return {
        [categories.SESSION] = {
          w = { ":Alpha<CR>", "dashboard" },
        },
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__alpha",
          pattern = "alpha",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell nolist nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs=",
        },
      },

      {
        "FileType",
        {
          group = "__alpha",
          pattern = "alpha",
          command = "nnoremap <silent> <buffer> q :q<CR>",
        },
      },
    },
    layout = {
      header = {
        [[                                                                                        ]],
        [[                                      ████▒▒▒▒██████                                    ]],
        [[                                    ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                  ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒    ▒▒    ▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██                              ]],
        [[                                ██▒▒▒▒▒▒  ██▒▒██  ▒▒▒▒▒▒██                              ]],
        [[                                  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██                                ]],
        [[                          ██████  ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██    ██                            ]],
        [[                          ██▒▒▒▒██  ██▒▒██▒▒▒▒▒▒██▒▒██████▒▒██  ██                      ]],
        [[                        ██████▒▒▒▒██▒▒▒▒▒▒██████▒▒▒▒██▒▒▒▒██  ██▒▒██                    ]],
        [[                      ██▒▒▒▒▒▒████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████  ██▒▒██                      ]],
        [[                        ██████▒▒▒▒▒▒▒▒██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒████▒▒██                        ]],
        [[                              ██████████▒▒▒▒▒▒██▒▒▒▒██▒▒▒▒▒▒██                          ]],
        [[                                    ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒██████████                        ]],
        [[                              ██████▒▒▒▒▒▒██▒▒██  ██▒▒▒▒▒▒▒▒▒▒▒▒██                      ]],
        [[                            ██▒▒▒▒▒▒▒▒▒▒██▒▒▒▒▒▒██  ████████████                        ]],
        [[                          ██▒▒██████████  ██▒▒▒▒▒▒██                                    ]],
        [[                          ████              ██████▒▒██                                  ]],
        [[                                                  ████                                  ]],
        [[                                                      ██                                ]],
        [[                                                                                        ]],
      },
      buttons = {
        { "SPC w l", (" %s  Load Last Session"):format(lvim.ui.icons.ui.History) },
        { "SPC w f", (" %s  Sessions"):format(lvim.ui.icons.ui.Target) },
        { "SPC p", (" %s  Find File"):format(lvim.ui.icons.ui.File) },
        { "SPC w p", (" %s  Recent Projects"):format(lvim.ui.icons.ui.Project) },
        { "SPC f f", (" %s  Recently Used Files"):format(lvim.ui.icons.ui.Files) },
        { "SPC P S", (" %s  Plugins"):format(lvim.ui.icons.ui.Gear) },
        { "q", (" %s  Quit"):format(lvim.ui.icons.ui.SignOut) },
      },
    },
  })
end

return M
