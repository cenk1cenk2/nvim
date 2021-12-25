local M = {}

local extension_name = "alpha"

M.config = function(config)
  lvim.extensions[extension_name] = {
    active = true,
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
  }
end

M.setup = function()
  local extension = require(extension_name)

  local lvim_version = require("lvim.bootstrap"):get_version "short"
  local nvim_version = require("lvim.bootstrap"):get_nvim_version()
  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/start", "*", 0, 1)
  local button = require("alpha.themes.dashboard").button

  local buttons = {}
  for _, value in ipairs(lvim.extensions[extension_name].setup.buttons) do
    table.insert(buttons, button(value[1], value[2]))
  end

  require("lvim.core.autocmds").define_augroups {
    _dashboard = {
      -- seems to be nobuflisted that makes my stuff disappear will do more testing
      {
        "FileType",
        "alpha",
        "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= ",
      },
      -- { "FileType", "alpha", "set showtabline=0 | autocmd BufLeave <buffer> set showtabline=1" },
      { "FileType", "alpha", "nnoremap <silent> <buffer> q :q<CR>" },
    },
  }

  extension.setup {
    layout = {
      { type = "padding", val = 1 },
      {
        type = "text",
        val = lvim.extensions[extension_name].setup.header,
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

  if lvim.extensions[extension_name].on_config_done then
    lvim.extensions[extension_name].on_config_done(extension)
  end
end

return M
