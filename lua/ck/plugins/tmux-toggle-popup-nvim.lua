-- https://github.com/cenk1cenk2/tmux-toggle-popup.nvim
local M = {}

M.name = "cenk1cenk2/tmux-toggle-popup.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- "cenk1cenk2/tmux-toggle-popup.nvim",
        dir = "~/development/tmux-toggle-popup.nvim",
      }
    end,
    setup = function()
      return {
        log_level = vim.log.levels.DEBUG,
      }
    end,
    on_setup = function(c)
      require("tmux-toggle-popup").setup(c)
    end,
    keymaps = function()
      if not vim.env["TMUX"] then
        return {}
      end

      return {
        {
          "<F1>",
          function()
            require("tmux-toggle-popup").toggle({ kill_on_vim_leave = true })
          end,
          desc = "toggle tmux popup",
        },
      }
    end,
    wk = function(_, categories, fn)
      if not vim.env["TMUX"] then
        return {}
      end

      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TERMINAL, "s" }),
          function()
            require("tmux-toggle-popup").save_session()
          end,
          desc = "save session for main terminal",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "S" }),
          function()
            require("tmux-toggle-popup").save_all()
          end,
          desc = "save session for all terminals",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "t" }),
          function()
            require("tmux-toggle-popup").toggle()
          end,
          desc = "toggle tmux popup",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "g" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "lazygit", command = { "lazygit" }, on_init = { "set status off" } })
          end,
          desc = "lazygit",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "g" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "lazygit", command = { "lazygit" }, on_init = { "set status off" } })
          end,
          desc = "lazygit",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "g" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "lazygit", command = { "lazygit" }, on_init = { "set status off" } })
          end,
          desc = "lazygit",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "d" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "lazydocker", command = { "lazydocker" }, on_init = { "set status off" } })
          end,
          desc = "lazydocker",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "k" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "k9s", command = { "k9s" }, on_init = { "set status off" } })
          end,
          desc = "k9s",
        },
        {
          fn.wk_keystroke({ categories.TERMINAL, "n" }),
          function()
            require("tmux-toggle-popup").toggle({ name = "dust", command = { "dust" }, on_init = { "set status off" } })
          end,
          desc = "dust",
        },
      }
    end,
  })
end

return M
