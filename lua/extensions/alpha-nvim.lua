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

      local function file_button(key, name, path)
        local element =
          button(key, name, (':cd %s | lua require("possession").load(require("possession.paths").cwd_session_name())<CR>'):format(vim.fn.fnameescape(path)), { silent = true })

        return element
      end

      local buttons = {}
      for _, value in ipairs(config.layout.buttons) do
        if value.path then
          table.insert(buttons, file_button(value.key, (" %s  %s"):format(value.icon, value.name), value.path))
        else
          table.insert(buttons, button(value.key, (" %s  %s"):format(value.icon, value.name)))
        end
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
          {
            type = "group",
            val = function()
              return {}
            end,
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
              redraw = true,
              position = "center",
              hl = "DashboardFooter",
            },
          },
          { type = "padding", val = 0 },
          -- {
          --   type = "text",
          --   val = { ("%s %s#%s"):format(lvim.ui.icons.git.Branch, require("lvim.utils.git").get_lvim_branch(), require("lvim.utils.git").get_lvim_current_sha()) },
          --   opts = {
          --     redraw = false,
          --     position = "center",
          --     hl = "DashboardFooter",
          --   },
          -- },
          -- { type = "padding", val = 0 },
          -- {
          --   type = "text",
          --   val = { ("%s %s"):format(lvim.ui.icons.ui.Gear, require("lvim.utils.git").get_nvim_version()) },
          --   opts = {
          --     redraw = false,
          --     position = "center",
          --     hl = "DashboardFooter",
          --   },
          -- },
        },
        opts = {
          margin = 5,
        },
      })
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.SESSION, "w" }),
          function()
            vim.cmd([[Alpha]])
          end,
          desc = "dashboard",
        },
      }
    end,
    autocmds = {
      require("modules.autocmds").set_view_buffer({ "alpha" }),

      require("modules.autocmds").q_close_autocmd({ "alpha" }),
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
        { key = "SPC w l", name = "Load Last Session", icon = lvim.ui.icons.ui.History },
        { key = "SPC w f", name = "Sessions", icon = lvim.ui.icons.ui.Target },
        { key = "SPC p", name = "Find File", icon = lvim.ui.icons.ui.File },
        { key = "SPC w p", name = "Recent Projects", icon = lvim.ui.icons.ui.Project },
        { key = "SPC f f", name = "Recently Used Files", icon = lvim.ui.icons.ui.Files },
        { key = "c", name = "~Config", path = join_paths(vim.env.HOME, "/.config/nvim/"), icon = lvim.ui.icons.ui.Gear },
        { key = "n", name = "~Notes", path = join_paths(vim.env.HOME, "/notes/"), icon = lvim.ui.icons.ui.Files },
        { key = "SPC P S", name = "Plugins", icon = lvim.ui.icons.ui.Gear },
        { key = "q", name = "Quit", icon = lvim.ui.icons.ui.SignOut },
      },
    },
  })
end

return M
