-- https://github.com/goolord/alpha-nvim
local M = {}

M.name = "alphagoolord/alpha-nvim"

function M.config()
  require("setup").define_extension(M.name, true, {
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
    on_setup = function(_, config)
      local button = require("alpha.themes.dashboard").button

      local function cb_button(key, name, cb)
        local element = button(key, name)
        element.on_press = cb
        element.opts.keymap = { "n", key, element.on_press, { noremap = true, silent = true, nowait = true } }

        return element
      end

      local function session_button(key, name, path)
        return cb_button(key, name, function()
          vim.cmd(("cd %s"):format(path))
          require("possession").load(require("possession.paths").cwd_session_name())
        end)
      end

      local button_text = function(icon, name)
        if not icon then
          return " " .. name
        end

        return ("%s  %s"):format(icon, name)
      end

      local buttons = {}
      for _, b in ipairs(M.layout.buttons) do
        if b.cb then
          table.insert(buttons, cb_button(b.key, button_text(b.icon, b.name), b.cb))
        elseif b.path then
          table.insert(buttons, session_button(b.key, button_text(b.icon, b.name), b.path))
        else
          table.insert(buttons, button(b.key, button_text(b.icon, b.name)))
        end
      end

      require("alpha").setup({
        layout = {
          { type = "padding", val = 1 },
          {
            type = "text",
            val = M.layout.header,
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

              return { ("%s %d/%d plugins in %s %.0fms"):format(nvim.ui.icons.ui.Package, stats.loaded, stats.count, nvim.ui.icons.misc.Watch, stats.startuptime) }
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
          --   val = { ("%s %s#%s"):format(nvim.ui.icons.git.Branch, require("core.version").get_nvim_branch(), require("core.version").get_nvim_current_sha()) },
          --   opts = {
          --     redraw = false,
          --     position = "center",
          --     hl = "DashboardFooter",
          --   },
          -- },
          -- { type = "padding", val = 0 },
          -- {
          --   type = "text",
          --   val = { ("%s %s"):format(nvim.ui.icons.ui.Gear, require("core.version").get_nvim_version()) },
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
    autocmds = function()
      return {
        require("modules.autocmds").set_view_buffer({ "alpha" }),

        require("modules.autocmds").q_close_autocmd({ "alpha" }),
      }
    end,
  })
end

M.layout = {
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
    { key = "SPC w l", name = "Load Last Session", icon = nvim.ui.icons.ui.History },
    { key = "SPC w f", name = "Sessions", icon = nvim.ui.icons.ui.Project },
    { key = "SPC p", name = "Find File", icon = nvim.ui.icons.ui.File },
    { key = "c", name = "~Config", path = join_paths(vim.env.HOME, ".config/nvim/"), icon = nvim.ui.icons.misc.Neovim },
    { key = "n", name = "~Notes", path = join_paths(vim.env.HOME, "notes/"), icon = nvim.ui.icons.misc.Obsidian },
    { key = "SPC w q", name = "Quit", icon = nvim.ui.icons.ui.SignOut },
  },
}

return M
