-- https://github.com/goolord/alpha-nvim
local M = {}

local extension_name = "alpha"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    packer = function(config)
      return {
        "goolord/alpha-nvim",
        event = "BufWinEnter",
        config = function()
          require("utils.setup").packer_config "alpha"
        end,
        disable = not config.active,
      }
    end,
    autocmds = {
      {
        "FileType",
        {
          group = "__alpha",
          pattern = "alpha",
          command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= ",
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
    on_setup = function(config)
      local extension = require "alpha"

      local lvim_version = require("lvim.utils.git").get_lvim_current_sha()
      local nvim_version = require("lvim.utils.git").get_nvim_version()
      local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/start", "*", 0, 1)
      local button = require("alpha.themes.dashboard").button

      local buttons = {}
      for _, value in ipairs(config.layout.buttons) do
        table.insert(buttons, button(value[1], value[2]))
      end

      extension.setup {
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
            val = { "Neovim loaded: " .. num_plugins_loaded .. " plugins " },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { lvim_version },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          {
            type = "text",
            val = { nvim_version },
            opts = {
              position = "center",
              hl = "DashboardFooter",
            },
          },
        },
        opts = {
          margin = 5,
        },
      }
    end,
    layout = {
      header = {
        [[                                                                                        ]],
        [[                                                                                        ]],
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
        [[                                                                                        ]],
        [[                                                                                        ]],
        [[                                                                                        ]],
      },
      buttons = {
        { "SPC w l", "  Load Last Session" },
        { "SPC w f", "⧗  Sessions" },
        { "SPC p", "  Find File" },
        { "SPC e", "  File Browser" },
        { "SPC w p", "  Recent Projects" },
        { "SPC f f", "  Recently Used Files" },
        { "SPC L c", "  Configuration" },
        { "q", "  Quit" },
      },
    },
  })
end

return M
