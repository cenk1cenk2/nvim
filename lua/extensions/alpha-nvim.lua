local M = {}

local setup = require "utils.setup"

local extension_name = "alpha"

function M.config()
  setup.define_extension(extension_name, true, {
    on_config_done = nil,
    setup = {
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

function M.setup()
  local extension = require(extension_name)
  local config = setup.get_config(extension_name)

  local lvim_version = require("lvim.utils.git").get_lvim_current_sha()
  local nvim_version = require("lvim.utils.git").get_nvim_version()
  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/start", "*", 0, 1)
  local button = require("alpha.themes.dashboard").button

  local buttons = {}
  for _, value in ipairs(config.setup.buttons) do
    table.insert(buttons, button(value[1], value[2]))
  end

  setup.define_autocmds {
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
  }

  extension.setup {
    layout = {
      { type = "padding", val = 1 },
      {
        type = "text",
        val = config.setup.header,
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

  setup.on_setup_done(config)
end

return M
